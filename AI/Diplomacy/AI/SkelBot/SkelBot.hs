{-# LANGUAGE DeriveDataTypeable, MultiParamTypeClasses, FunctionalDependencies #-}

module Diplomacy.AI.SkelBot.SkelBot (skelBot) where

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
type Master = ReaderT (TSeq InMessage, TSeq OutMessage) (CommT DaideMessage DaideMessage DaideHandle)

skelBot :: DipBot Master h -> IO ()
skelBot bot = do
  updateGlobalLogger "Main" (setLevel NOTICE)
  opts <- getCmdlineOpts
  noticeM "Main" $ "Connecting to " ++ show (clOptsServer opts) ++
    ':' : show (clOptsPort opts)
  withSocketsDo $ do
    hndle <- connectToServer (clOptsServer opts) (fromIntegral . clOptsPort $ opts)
    runDaide (communicate bot) hndle

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
    _ -> throwError RMNotFirst

  -- Create messaging queues that interface with the Brain
  brainIn <- liftIO (newTSeqIO :: IO (TSeq InMessage))
  brainOut <- liftIO (newTSeqIO :: IO (TSeq OutMessage))

  -- Create lower level messaging queues that interface with Master
  masterIn <- liftIO (newTSeqIO :: IO (TSeq DaideMessage))
  masterOut <- liftIO (newTSeqIO :: IO (TSeq DaideMessage))

  -- Create messaging threads
  hndleInfo <- ask
  liftIO . forkIO $ runDaide (runDaideAsk (receiver masterIn brainIn)) hndleInfo
  liftIO . forkIO $ runDaide (runDaideTell (dispatcher masterOut brainOut)) hndleInfo

  runCommT (runReaderT (master bot) (brainIn, brainOut)) masterIn masterOut

master :: DipBot Master h -> Master ()
master bot = do
  gameInfo <- initGame
  -- create TVars for getting partial move
  ordMoveVar <- liftIO $ newTVarIO Nothing
  ordRetreatVar <- liftIO $ newTVarIO Nothing
  ordBuildVar <- liftIO $ newTVarIO Nothing

  -- initialise history
  initHist <- dipBotInitHistory bot

  let mapDef = gameInfoMapDef gameInfo

  -- Run the main game loop
  (\loop -> runGameKnowledgeT loop gameInfo initHist) . forever $ do
    moveOrder <- execBrain (dipBotBrainMovement bot) ordMoveVar
    execBrain (dipBotBrainRetreat bot) ordRetreatVar
    execBrain (dipBotBrainBuild bot) ordBuildVar
  return ()

execBrain :: (OrderClass o) =>
             BrainCommT o h Master () -> TVar (Maybe o) ->
             GameKnowledgeT h Master Order
execBrain botBrain ordVar = do
  (brainIn, brainOut) <- lift ask
  gameState <- lift getGameState
  let gameKnowledge = liftM snd . flip runBrainT gameState
                      $ runBrainCommT botBrain ordVar brainIn brainOut
  morder <- runMaybeT $ do
    -- run the brain
    let earlyFinish = runGameKnowledgeTTimed
                      undefined {-(gameInfoTimeout gameInfo)-} gameKnowledge
    -- check TVar if timed out
    let timeoutFinish = MaybeT . liftIO . atomically $ readTVar ordVar
    earlyFinish `mplus` timeoutFinish
  -- die if no move, ordify if there is a move
  orderMsg <- (\err -> maybe err (return . ordify) morder) $ do
    lift . lift . lift $ throwError (WillDieSorry "Brain timed out with no partial move")
  -- clear ordVar
  liftIO . atomically $ writeTVar ordVar Nothing
  return orderMsg
          -- undefined -- mapM_ tellHandle messages   -- send the messages
          -- -- TODO: check negative server response here
          -- results <- lift getMoveResults       -- get move results
          -- modifyHistory (dipBotProcessResults bot results)

runGameKnowledgeTTimed :: MonadIO m => Int -> GameKnowledgeT h m (Maybe a) -> MaybeT (GameKnowledgeT h m) a
runGameKnowledgeTTimed timedelta gameKnowledge = do
  gameIO <- lift $ liftM return gameKnowledge
  m <- liftIO $ timeout timedelta gameIO
  maybe mzero (MaybeT . return) m

initGame :: Master GameInfo
initGame = undefined

getGameState :: Master GameState
getGameState = undefined

getMoveResults :: Master Results
getMoveResults = undefined

dispatcher :: TSeq DaideMessage -> TSeq OutMessage -> DaideTell ()
dispatcher masterOut brainOut = forever $ do
  msg <- liftIO . atomically $
         (return . Left =<< readTSeq masterOut)
         `orElse`
         (return . Right =<< readTSeq brainOut)
  tellDaide . either id (DM . SendPress Nothing) $ msg

receiver :: TSeq DaideMessage -> TSeq InMessage -> DaideAsk ()
receiver masterIn brainIn = forever $ do
  msg <- askDaide
  case msg of
    (IM _) -> throwError IMFromServer
    RM -> throwError ManyRMs
    FM -> undefined
    (DM dm) -> undefined -- communicate with brain
    (EM _) -> undefined
    _ -> undefined
    
  undefined
  -- atomically (writeTSeq q msg)

handleMessage :: DaideMessage -> DaideHandle ()
handleMessage (IM _) = throwError IMFromServer
handleMessage RM = throwError ManyRMs
handleMessage FM = undefined
handleMessage (DM dm) = undefined -- communicate with brain
handleMessage (EM _) = undefined
handleMessage _ = undefined

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

