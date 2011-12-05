{-# LANGUAGE GeneralizedNewtypeDeriving, FlexibleInstances, DeriveDataTypeable, MultiParamTypeClasses, FunctionalDependencies #-}

module Diplomacy.AI.SkelBot.SkelBot (skelBot, Master(..)) where

import Diplomacy.Common.DaideHandle
import Diplomacy.Common.DaideMessage
import Diplomacy.Common.DaideError
import Diplomacy.Common.DipMessage
import Diplomacy.Common.Data
import Diplomacy.Common.Press
import Diplomacy.Common.TSeq

import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Comm
import Diplomacy.AI.SkelBot.GameInfo
import Diplomacy.AI.SkelBot.DipBot

import Control.Monad
import Control.Monad.Maybe
import Control.Monad.Error
import Control.Monad.Reader
import Control.Monad.State
import Control.Concurrent.STM
import Control.Concurrent
import System.Timeout
import System.Log.Logger
import System.Console.CmdArgs
import System.Environment
import System.IO
import System.Posix
import Network
import Network.BSD

  -- Master thread's monad
newtype MasterT m a = Master { unMaster :: (ReaderT (TSeq InMessage, TSeq OutMessage)
                                            (CommT DaideMessage DaideMessage m) a)}
                    deriving (Monad, MonadIO, MonadReader (TSeq InMessage, TSeq OutMessage))

type Master = MasterT DaideHandle
 
instance MonadTrans MasterT where
  lift = Master . lift . lift

instance (MonadIO m) => MonadComm DaideMessage DaideMessage (MasterT m) where
  pushMsg = Master . lift . pushMsg
  popMsg = Master . lift $ popMsg

instance DaideErrorClass (MasterT DaideHandle) where
  throwEM = Master . lift . lift . throwEM
  
skelBot :: DipBot Master h -> IO ()
skelBot bot = do
  updateGlobalLogger "Main" (setLevel NOTICE)
  opts <- getCmdlineOpts
  noticeM "Main" $ "Connecting to " ++ show (clOptsServer opts) ++
    ':' : show (clOptsPort opts)
  withSocketsDo $ do
    hndle <- connectToServer (clOptsServer opts) (fromIntegral . clOptsPort $ opts)
    runDaideT (communicate bot) hndle

connectToServer :: String -> PortNumber -> IO DaideHandleInfo
connectToServer server port = do
  hndle <- connectTo server (PortNumber port)
  hSetBuffering hndle NoBuffering
  hostName <- getHostName
  return (Handle hndle hostName port)

communicate :: DipBot Master h -> DaideHandle ()
communicate bot = do
  note "Connection established, sending initial message"
  runDaideTell $ tellDaide (IM (fromIntegral _DAIDE_VERSION))
  replyMessage <- runDaideAsk askDaide
  case replyMessage of
    RM -> return ()
    _ -> throwEM RMNotFirst

  -- Create messaging queues that interface with the Brain
  brainIn <- liftIO (newTSeqIO :: IO (TSeq InMessage))
  brainOut <- liftIO (newTSeqIO :: IO (TSeq OutMessage))

  -- Create lower level messaging queues that interface with Master
  masterIn <- liftIO (newTSeqIO :: IO (TSeq DaideMessage))
  masterOut <- liftIO (newTSeqIO :: IO (TSeq DaideMessage))

  -- Create messaging threads
  hndleInfo <- ask
  liftIO . forkIO $ runDaideT (runDaideAsk (receiver masterIn brainIn)) hndleInfo
  liftIO . forkIO $ runDaideT (runDaideTell (dispatcher masterOut brainOut)) hndleInfo
  
  note "Starting master"
  -- run master
  runCommT (runReaderT (unMaster (master bot))
            (brainIn, brainOut))
    masterIn masterOut
  return ()

expectWith :: (DipMessage -> Master ()) -> DipMessage -> Master ()
expectWith f msg = do
  rmsg <- popDip
  if msg == rmsg then return () else f rmsg

expect :: DipMessage -> Master ()
expect = expectWith (\msg -> dieUnexpected msg)

die = throwEM . WillDieSorry
dieUnexpected = die . ("Unexpected message: " ++) . show

popDip :: Master DipMessage
popDip = do
  msg <- popMsg
  case msg of
    IM _ -> throwEM IMFromServer
    RM -> throwEM ManyRMs
    FM -> die "Final message received"
    EM err -> die (show err)
    DM dm -> return dm

pushDip :: DipMessage -> Master ()
pushDip = pushMsg . DM

master :: DipBot Master h -> Master ()
master bot = do
  
  let nameMsg = Name (dipBotName bot) (show $ dipBotVersion bot)
  pushDip nameMsg
  expect (Accept nameMsg)
  
  mapName <- popDip
  case mapName of
    n@(MapName _) -> return n
    m -> dieUnexpected m
  
  pushDip MapDefReq
  mapDef <- popDip
  mapDefinition <- case mapDef of
    MapDef def -> return def
    m -> dieUnexpected m

  pushDip (Accept mapName)

  start <- popDip 
  (power, startCode) <- case start of
    Start pow pass _ _ -> return (pow, pass)
    m -> dieUnexpected m
  
  gameInfo <- initGame
  -- create TVars for getting partial move
  ordVar <- liftIO $ newTVarIO Nothing

  gameState <- getGameState


  -- initialise history
  initHist <- dipBotInitHistory bot

  let mapDef = gameInfoMapDef gameInfo
  let timeout = gameInfoTimeout gameInfo
  
  -- Run the main game loop
  (\loop -> runGameKnowledgeT loop gameInfo initHist) . forever $ do
    moveOrders <- execBrain (dipBotBrainMovement bot) timeout gameState ordVar
    execPureBrain (dipBotBrainRetreat bot) timeout gameState
    execPureBrain (dipBotBrainBuild bot) timeout gameState
  return ()

execPureBrain :: (OrderClass o) => Brain o h () -> Int ->
                 GameState -> GameKnowledgeT h Master [Order]
execPureBrain brain timeout gameState = do
  morders <- runMaybeT . runGameKnowledgeTTimed timeout . liftM snd
             $ runBrainT (mapBrain return brain) gameState
  orders <- (\err -> maybe err (return . map ordify) morders) $ do
    lift $ throwEM (WillDieSorry "Pure brain timed out")
  return orders

execBrain :: (OrderClass o) => BrainCommT o h Master () -> Int -> GameState -> 
             TVar (Maybe [o]) -> GameKnowledgeT h Master [Order]
execBrain botBrain timeout gameState ordVar = do
  (brainIn, brainOut) <- lift ask
  let gameKnowledge = liftM snd . flip runBrainT gameState
                      $ runBrainCommT botBrain ordVar brainIn brainOut
  morders <- runMaybeT $ do
    -- run the brain
    let earlyFinish = runGameKnowledgeTTimed timeout gameKnowledge
    -- check TVar if timed out
    let timeoutFinish = MaybeT . liftIO . atomically $ readTVar ordVar
    earlyFinish `mplus` timeoutFinish
  -- die if no move, ordify if there is a move
  orders <- (\err -> maybe err (return . map ordify) morders) $ do
    lift $ throwEM (WillDieSorry "Brain timed out with no partial move")
  -- clear ordVar
  liftIO . atomically $ writeTVar ordVar Nothing
  return orders

runGameKnowledgeTTimed :: MonadIO m => Int -> GameKnowledgeT h m (Maybe a) -> MaybeT (GameKnowledgeT h m) a
runGameKnowledgeTTimed timedelta gameKnowledge = do
  gameIO <- lift $ liftM return gameKnowledge
  m <- liftIO $ timeout timedelta gameIO
  maybe mzero (MaybeT . return) m

initGame :: Master GameInfo
initGame = error "come on"

getGameState :: Master GameState
getGameState = return (error "come on")

getMoveResults :: Master Results
getMoveResults = error "come on"

dispatcher :: TSeq DaideMessage -> TSeq OutMessage -> DaideTell ()
dispatcher masterOut brainOut = forever $ do
  msg <- liftIO . atomically $
         (return . Left =<< readTSeq masterOut)
         `orElse`
         (return . Right =<< readTSeq brainOut)
  note $ "Dispatching message" ++ show msg
  tellDaide . either id (DM . SendPress Nothing) $ msg
  note "message dispatched"

receiver :: TSeq DaideMessage -> TSeq InMessage -> DaideAsk ()
receiver masterIn brainIn = forever $ do
  msg <- askDaide
  case msg of
    m@(DM dm) -> case dm of
      (ReceivePress p) -> liftIO . atomically $ writeTSeq brainIn p
      _ -> liftIO . atomically $ writeTSeq masterIn m
    other -> liftIO . atomically $ writeTSeq masterIn other

-- command line options
data CLOpts = CLOptions
              { clOptsPort :: Int
              , clOptsServer :: String
              } deriving (Data, Typeable, Show)


getCmdlineOpts = do
  progName <- getProgName
  cmdArgs $ CLOptions
       { clOptsPort = 16713         &= argPos 1 &= typ "PORT"
       , clOptsServer = "localhost" &= argPos 0 &= typ "ADDRESS"
       }
       &= program progName
       &= summary "Flappy HoldBot 0.1"

