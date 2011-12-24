{-# LANGUAGE GeneralizedNewtypeDeriving, FlexibleInstances, DeriveDataTypeable, MultiParamTypeClasses, FunctionalDependencies #-}

module Diplomacy.AI.SkelBot.SkelBot (skelBot, Master(..)) where

import Diplomacy.Common.DaideHandle
import Diplomacy.Common.DaideMessage
import Diplomacy.Common.DaideError
import Diplomacy.Common.DipMessage
import Diplomacy.Common.DipError
import Diplomacy.Common.Data
import Diplomacy.Common.Press
import Diplomacy.Common.TSeq

import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Comm
import Diplomacy.AI.SkelBot.Common
import Diplomacy.AI.SkelBot.DipBot

import Data.Maybe
import Data.List
import Control.Applicative
import Control.Monad
import Control.Monad.Maybe
import Control.Monad.Error
import Control.Monad.Reader
import Control.Monad.State
import Control.Monad.Loops
import Control.Concurrent.STM
import Control.Concurrent
import System.Timeout
import System.Log.Logger
import System.Console.CmdArgs
import System.Environment
import System.IO
--import System.Posix
import Network
import Network.BSD

import qualified Data.Map as Map

  -- Master thread's monad
newtype MasterT m a = Master { unMaster :: (ReaderT (ThreadId, ThreadId) -- for shutting down
                                            (ReaderT (TSeq InMessage, TSeq OutMessage)
                                             (CommT DaideMessage DaideMessage m)) a)}
                    deriving (Functor, Monad, MonadIO, MonadReader (ThreadId, ThreadId))

type Master = MasterT DaideHandle

instance MonadTrans MasterT where
  lift = Master . lift . lift . lift

instance (MonadIO m) => MonadComm DaideMessage DaideMessage (MasterT m) where
  pushMsg = Master . lift . lift . pushMsg
  popMsg = Master . lift . lift $ popMsg
  peekMsg = Master . lift . lift $ peekMsg
  pushBackMsg = Master . lift . lift . pushBackMsg

instance DaideErrorClass (MasterT DaideHandle) where
  throwEM = Master . lift . lift . lift . throwEM

runMaster :: Master a -> DaideHandle a
runMaster master = do
  -- Create messaging queues that interface with the Brain
  brainIn <- liftIO (newTSeqIO :: IO (TSeq InMessage))
  brainOut <- liftIO (newTSeqIO :: IO (TSeq OutMessage))

  -- Create lower level messaging queues that interface with Master
  masterIn <- liftIO (newTSeqIO :: IO (TSeq DaideMessage))
  masterOut <- liftIO (newTSeqIO :: IO (TSeq DaideMessage))

  -- Create messaging threads
  hndleInfo <- ask
  t1 <- liftIO . forkIO $ runDaideT (runDaideAsk (receiver masterIn brainIn)) hndleInfo
  t2 <- liftIO . forkIO $ runDaideT (runDaideTell (dispatcher masterOut brainOut)) hndleInfo

  note "Starting master"
  -- run master
  runCommT (runReaderT (runReaderT (unMaster master)
                        (t1, t2))
            (brainIn, brainOut))
    masterIn masterOut  

shutdownMaster :: Master a
shutdownMaster = do
  (t1, t2) <- Master ask
  liftIO $ killThread t1
  liftIO $ killThread t2
  lift shutdownDaide
  
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

  runMaster (masterThread bot)

  return ()

expectWith :: (DipMessage -> Master ()) -> DipMessage -> Master ()
expectWith f msg = do
  rmsg <- popDip
  if msg == rmsg then return () else f rmsg

expect :: DipMessage -> Master ()
expect = expectWith (\msg -> dieUnexpected msg)

die = throwEM . WillDieSorry
dieUnexpected = die . ("Unexpected message: " ++) . show  

requeueDip :: DipMessage -> Master ()
requeueDip = pushBackMsg . DM

popDip :: Master DipMessage
popDip = do
  msg <- popMsg
  case msg of
    IM _ -> throwEM IMFromServer
    RM -> throwEM ManyRMs
    FM -> shutdownMaster
    EM err -> do
      lift . note $ "EM : " ++ show err
      shutdownMaster
    DM dm -> handleGeneral dm

-- |handle general messages
-- put here anything that can be received at an arbitrary point in time!
             -- RESUME HERE implement shutdownMaster for shutting down queues safely
handleGeneral :: DipMessage -> Master DipMessage
handleGeneral m = case m of
  ExitClient -> pushMsg FM >> shutdownMaster
  SoloWinGame pow -> do
    lift . note $ "Solo win: " ++ show pow
    popDip
  DrawGame mPowers -> do
    lift . note $ "Draw" ++ maybe "" ((": " ++) . show) mPowers
    popDip
  DipError (CivilDisorder _) -> popDip -- it dont make no difference to me baby
  DipError err -> do
    lift . note $ "DipError: " ++ show err
    pushMsg FM >> shutdownMaster
  EndGameStats turn stats -> do
    lift . note $ "End Game Statistics (" ++ show turn ++ "):\n" ++ show stats
    popDip
  otherMsg -> return otherMsg


pushDip :: DipMessage -> Master ()
pushDip = pushMsg . DM

masterThread :: DipBot Master h -> Master ()
masterThread bot = do

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

  -- initialise history
  initHist <- dipBotInitHistory bot -- pass in mapDef?

  start <- popDip
  (power, startCode) <- case start of
    Start pow pass _ _ -> return (pow, pass)
    m -> dieUnexpected m

  sco <- popDip
  scos <- case sco of
    CurrentPosition sc -> return sc
    m -> dieUnexpected m

  --pushDip CurrentUnitPositionReq
  now <- popDip
  (turn, unitPoss) <- case now of
    CurrentUnitPosition turn up -> return (turn, up)
    m -> do
      dieUnexpected m

  let gameInfo = GameInfo { gameInfoMapDef = mapDefinition
                          , gameInfoTimeout = 60 * 10 ^ 6
                          , gameInfoPower = power }

  let initState = GameState { gameStateMap = MapState { supplyOwnerships = scos
                                                      , unitPositions = unitPoss }
                            , gameStateTurn = turn }

  let mapDef = gameInfoMapDef gameInfo
  let timeout = gameInfoTimeout gameInfo

  lift . note $ "Starting main game loop"
  -- Run the main game loop
  _ <- runStateT (runGameKnowledgeT (gameLoop bot timeout)
                  gameInfo initHist
                 )
       initState
  return ()

  -- TODO flush press messaging queue when turn is finished/starting!

gameLoop :: DipBot Master h -> Int -> GameKnowledgeT h (StateT GameState Master) ()
gameLoop bot timeout = do
  -- create TVar for getting partial move
  let brainMap = Map.fromList
                 [ (Spring, execBrain (dipBotBrainMovement bot) timeout)
                 , (Summer, execBrain (dipBotBrainRetreat bot) timeout)
                 , (Fall,   execBrain (dipBotBrainMovement bot) timeout)
                 , (Autumn, execBrain (dipBotBrainRetreat bot) timeout)
                 , (Winter, execBrain (dipBotBrainBuild bot) timeout) ]

  -- lifts be here
  forever $ do
    (GameState (MapState scos _) turn) <- lift get
    let ebrain = brainMap Map.! turnPhase turn

    -- sort so that we can do some checks on the responses
    -- TODO sanity checks on orders (all units are taken care of, validity)
    moveOrders <- return . sort =<< ebrain
    
    lift . lift $ do            -- not concerned with history/gamestate yet
      
      -- dont submit empty order list
      when (moveOrders /= []) $ pushDip $ SubmitOrder (Just turn) moveOrders
      respOrders <- unfoldM $ do
        resp <- popDip
        case resp of
          AckOrder order ordNote -> return (Just (order, ordNote))
          other -> requeueDip other >> return Nothing
    
      let sortedRespOrders = sortBy (\(o1, _) (o2, _) -> compare o1 o2) respOrders
      when (length moveOrders /= length sortedRespOrders) $ do
        lastMsg <- popDip
        die $ "Acknowledging messages missing, last message: " ++ show lastMsg

      zipWithM_ (\o1 (o2, oNote) -> do
                    when (o1 /= o2) $
                      die $ "Acknowledging messages don't match orders"
                    when (oNote /= MovementOK) . die $
                      "Server returned \"" ++ show oNote ++
                      "\" for order \"" ++ show o1 ++ "\""
                ) moveOrders sortedRespOrders

      mMissing <- popDip
      case mMissing of
        (Missing _) -> do
          lift . note $ show mMissing
          die $ "Missing orders, can't handle for now"
        other -> requeueDip other

    resultOrders <- lift . lift . unfoldM $ do
      res <- popDip
      case res of
        OrderResult trn order result -> do
          when (turn /= trn) . die $
            "OrderResults for wrong turn (Got " ++ show trn ++
            ", expected " ++ show turn ++ ")"
          return (Just (order, result))
        other -> requeueDip other >> return Nothing
      
    -- process results, save new history
    modifyHistory (dipBotProcessResults bot resultOrders)
      
      -- new SCO
    newScos <- lift . lift $ do
      sco <- popDip
      mscos <- case sco of
        CurrentPosition sc -> return (Just sc)
        other -> requeueDip other >> return Nothing
      return (maybe scos id mscos)

      -- new NOW
    (newTurn, newUnitPoss) <- lift . lift $ do
      now <- popDip
      case now of
        CurrentUnitPosition turn up -> return (turn, up)
        m -> dieUnexpected m
        
    checkLost newScos newUnitPoss

    -- change state
    lift . put $ GameState { gameStateMap = MapState newScos newUnitPoss 
                           , gameStateTurn = newTurn }

    
-- |check whether we've lost
checkLost :: SupplyCOwnerships -> UnitPositions ->
             GameKnowledgeT h (StateT GameState Master) ()
checkLost (SupplyCOwnerships supplies) (UnitPositions up) = do
  myPower <- getMyPower
  when (isNothing (Map.lookup myPower supplies) &&
        isNothing (Map.lookup myPower up))
    . lift . lift $ do
    lift . note $ "i lost i guess?"
    pushMsg FM >> shutdownMaster
checkLost _ _ = return ()

-- execPureBrain :: (OrderClass o) => Brain o h () -> Int ->
--                  GameKnowledgeT h (StateT GameState Master) [Order]
-- execPureBrain brain timeout = do
--   gameState <- lift get
--   morders <- runMaybeT . runGameKnowledgeTTimed timeout . liftM snd
--              $ runBrainT (mapBrain return brain) gameState
--   orders <- (\err -> maybe err (return . map ordify) morders) $ do
--     lift . lift $ throwEM (WillDieSorry "Pure brain timed out")
--   return orders

execBrain :: (OrderClass o) => BrainCommT o h Master () -> Int ->
             GameKnowledgeT h (StateT GameState Master) [Order]
execBrain botBrain timeout = do
  gameState <- lift get
  (brainIn, brainOut) <- lift . lift . Master . lift $ ask
  ordVar <- liftIO $ newTVarIO Nothing
  let gameKnowledge = liftM snd . flip runBrainT gameState
                      . mapBrainT lift
                      $ runBrainCommT botBrain ordVar brainIn brainOut
  morders <- runMaybeT $ do
    -- run the brain
    let earlyFinish = runGameKnowledgeTTimed timeout gameKnowledge
    -- check TVar if timed out
    let timeoutFinish = MaybeT . liftIO . atomically $ readTVar ordVar
    earlyFinish `mplus` timeoutFinish
  -- die if no move, ordify if there is a move
  orders <- (\err -> maybe err (return . map ordify) morders) $ do
    lift . lift $ throwEM (WillDieSorry "Brain timed out with no partial move")
  -- clear ordVar
  liftIO . atomically $ writeTVar ordVar Nothing
  return orders

runGameKnowledgeTTimed :: MonadIO m => Int -> GameKnowledgeT h m (Maybe a) -> MaybeT (GameKnowledgeT h m) a
runGameKnowledgeTTimed timedelta gameKnowledge = do
  gameIO <- lift $ liftM return gameKnowledge
  m <- liftIO $ timeout timedelta gameIO
  maybe mzero (MaybeT . return) m

dispatcher :: TSeq DaideMessage -> TSeq OutMessage -> DaideTell ()
dispatcher masterOut brainOut = forever $ do
  msg <- liftIO . atomically $
         (return . Left =<< readTSeq masterOut)
         `orElse`
         (return . Right =<< readTSeq brainOut)
  -- note ("(DISPATCHING) " ++ show msg)
  tellDaide . either id (DM . SendPress Nothing) $ msg

receiver :: TSeq DaideMessage -> TSeq InMessage -> DaideAsk ()
receiver masterIn brainIn = forever $ do
  msg <- askDaide
  -- note $ ("(RECEIVING) " ++ show msg)
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

