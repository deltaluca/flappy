{-# LANGUAGE GeneralizedNewtypeDeriving, FlexibleInstances, DeriveDataTypeable, MultiParamTypeClasses, FunctionalDependencies, TypeSynonymInstances, MonadComprehensions #-}

-- |SkelBot is the skeleton bot that all bots build on top of. tread lightly

module Diplomacy.AI.SkelBot.SkelBot (skelBot, Master) where

import Diplomacy.Common.DaideHandle
import Diplomacy.Common.DaideMessage
import Diplomacy.Common.DaideError
import Diplomacy.Common.DipMessage
import Diplomacy.Common.DipError
import Diplomacy.Common.Data
import Diplomacy.Common.Press
import Diplomacy.Common.TSeq
import Diplomacy.Common.TStream

import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Comm
import Diplomacy.AI.SkelBot.Common
import Diplomacy.AI.SkelBot.DipBot

import Data.Maybe
import Data.List
import Control.Applicative hiding (many, (<|>))
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

-- import qualified Control.Exception as Exc
-- import qualified Control.DeepSeq as DS
import qualified Text.Parsec.Prim as Parsec
import qualified Data.Map as Map

  -- Master thread's monad
newtype MasterT h m a = Master { unMaster :: ReaderT (ThreadId, ThreadId) -- for shutting down
                                             (ReaderT (TSeq InMessage, TSeq OutMessage)
                                              (CommT DaideMessage DaideMessage
                                               (ReaderT (DipBot (Master h) h) m))) a }
                      deriving (Functor, Monad, MonadIO, MonadReader (ThreadId, ThreadId))

type Master h = MasterT h DaideHandle

instance MonadTrans (MasterT h) where
  lift = Master . lift . lift . lift . lift

instance (Monad m) => MonadComm DaideMessage DaideMessage (MasterT h m) where
  pushMsg = Master . lift . lift . pushMsg
  popMsg = Master . lift . lift $ popMsg
  peekMsg = Master . lift . lift $ peekMsg
  pushBackMsg = Master . lift . lift . pushBackMsg

instance DaideErrorClass (MasterT h DaideHandle) where
  throwEM = lift . throwEM

newtype Protocol h a = Protocol { unProtocol :: Parsec.ParsecT (TStream DaideMessage) ()
                                                (Master h) a }
                   deriving (Functor, MonadIO)

instance Monad (Protocol h) where
  return = Protocol . return
  ma >>= f = Protocol $ unProtocol ma >>= unProtocol . f
  fail = Protocol . Parsec.parserFail

instance MonadComm DaideMessage DaideMessage (Protocol h) where
  pushMsg = Protocol . lift . pushMsg
  popMsg = Protocol . lift $ popMsg
  peekMsg = Protocol . lift $ peekMsg
  pushBackMsg = Protocol . lift . pushBackMsg
  
instance DaideErrorClass (Protocol h) where
  throwEM = liftMaster . throwEM

liftMaster :: Master h a -> Protocol h a
liftMaster = Protocol . lift

runMaster :: DipBot (Master h) h -> Master h a -> DaideHandle a
runMaster bot master = do
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
  runReaderT (runCommT (runReaderT (runReaderT (unMaster master)
                                    (t1, t2))
                        (brainIn, brainOut))
              masterIn masterOut)
    bot

shutdownMaster :: Master h a
shutdownMaster = do
  (t1, t2) <- Master ask
  liftIO $ killThread t1
  liftIO $ killThread t2
  lift shutdownDaide
  
askBot :: Master h (DipBot (Master h) h)
askBot = Master . lift . lift . lift $ ask

asksBot :: (DipBot (Master h) h -> a) -> Master h a
asksBot f = liftM f askBot

skelBot :: DipBot (Master h) h -> IO ()
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
  hostNam <- getHostName
  return (Handle hndle hostNam port)

communicate :: DipBot (Master h) h -> DaideHandle ()
communicate bot = do
  note "Connection established, sending initial message"
  runDaideTell $ tellDaide (IM (fromIntegral _DAIDE_VERSION))
  replyMessage <- runDaideAsk askDaide
  case replyMessage of
    RM -> return ()
    _ -> throwEM RMNotFirst

  runMaster bot (runProtocol protocol)

  return ()

runProtocol :: Protocol h a -> Master h a
runProtocol (Protocol prot) = do
  stmPop <- popMsg
  e <- Parsec.runParserT prot () "" =<< newTStream stmPop
  either (throwEM . WillDieSorry . show) return e

tokenPrim a b c = Protocol $ Parsec.tokenPrim a b c
parserZero = Protocol Parsec.parserZero
parserFail = Protocol . Parsec.parserFail
--many = Protocol . Parsec.many . unProtocol
try = Protocol . Parsec.try . unProtocol
a <|> b = Protocol $ unProtocol a Parsec.<|> unProtocol b

manyTry :: Protocol h a -> Protocol h [a]
manyTry p = unfoldM ((try p >>= return . Just) <|> return Nothing)

-- dipMsg for Protocol
dipMsgPlain :: (DipMessage -> Protocol h (Maybe a)) -> Protocol h a
dipMsgPlain f = do
  daide <- tokenPrim show (const . const) Just
  case daide of
    IM _ -> throwEM IMFromServer
    RM -> throwEM ManyRMs
    FM -> liftMaster shutdownMaster
    EM err -> liftMaster $ do
      lift . note $ "EM : " ++ show err
      shutdownMaster
  -- put here anything that can be received at an arbitrary point in time!
             -- RESUME HERE implement shutdownMaster for shutting down queues safely
    DM dm -> case dm of
      ExitClient -> liftMaster $ pushMsg FM >> shutdownMaster
      SoloWinGame pow -> do
        liftMaster . lift . note $ "Solo win: " ++ show pow
        dipMsgPlain f
      DrawGame mPowers -> do
        liftMaster . lift . note $ "Draw" ++ maybe "" ((": " ++) . show) mPowers
        dipMsgPlain f
      DipError (CivilDisorder _) -> dipMsgPlain f -- it dont make no difference to me baby
      DipError err -> liftMaster $ do
        lift . note $ "DipError: " ++ show err
        pushMsg FM >> shutdownMaster
      EndGameStats turn stats -> liftMaster $ do
        lift . note $ "End Game Statistics (" ++ show turn ++ "):\n" ++ show stats
        pushMsg FM >> shutdownMaster
      otherMsg -> maybe parserZero return =<< f otherMsg

-- dipMsg for when we have gameknowledge context. only difference is it calls gameover hook
dipMsg :: (DipMessage -> GameKnowledgeT h (StateT GameState (Protocol h)) (Maybe a)) ->
          GameKnowledgeT h (StateT GameState (Protocol h)) a
dipMsg f = do
  hist <- getHistory
  info <- askGameInfo
  daide <- lift . lift $ tokenPrim show (const . const) Just
  let gameOver = liftMaster $ do
        go <- asksBot dipBotGameOver
        _ <- runGameKnowledgeT go info hist
        return ()
  case daide of
    IM _ -> lift . lift $ throwEM IMFromServer
    RM -> lift . lift $ throwEM ManyRMs
    FM -> lift . lift $ liftMaster shutdownMaster
    EM err -> lift . lift $ liftMaster $ do
      lift . note $ "EM : " ++ show err
      shutdownMaster
  -- put here anything that can be received at an arbitrary point in time!
             -- RESUME HERE implement shutdownMaster for shutting down queues safely
    DM dm -> case dm of
      ExitClient -> do
        lift . lift $ liftMaster $ pushMsg FM >> shutdownMaster
      SoloWinGame pow -> do
        lift . lift $ liftMaster . lift . note $ "Solo win: " ++ show pow
        dipMsg f
      DrawGame mPowers -> do
        lift . lift $ liftMaster . lift . note $ "Draw" ++ maybe "" ((": " ++) . show) mPowers
        dipMsg f
      DipError (CivilDisorder _) -> dipMsg f -- it dont make no difference to me baby
      DipError err -> lift . lift $ liftMaster $ do
        lift . note $ "DipError: " ++ show err
        pushMsg FM >> shutdownMaster
      EndGameStats turn stats -> lift . lift $ do
        gameOver
        liftMaster $ do
          lift . note $ "End Game Statistics (" ++ show turn ++ "):\n" ++ show stats
          pushMsg FM >> shutdownMaster
      otherMsg -> maybe (lift . lift $ parserZero) return =<< f otherMsg

dipMsgPlain1 :: DipMessage -> Protocol h DipMessage
dipMsgPlain1 msg = dipMsgPlain (\rmsg -> return $ if rmsg == msg
                                                  then Just msg
                                                  else Nothing)

nextDip :: GameKnowledgeT h (StateT GameState (Protocol h)) DipMessage
nextDip = dipMsg (return . Just)

nextDipPlain :: Protocol h DipMessage
nextDipPlain = dipMsgPlain (return . Just)

pushDip :: DipMessage -> Protocol h ()
pushDip msg = liftIO . atomically =<< pushMsg (DM msg)


protocol :: Protocol h ()
protocol = do
  nameMsg <- liftMaster $ liftM2 Name
             (asksBot dipBotName)
             (liftM show $
              asksBot dipBotVersion)
  pushDip nameMsg  
  dipMsgPlain1 (Accept nameMsg)

  MapName mapName <- nextDipPlain

  -- BOTTLENECK (?) always request mapdefinition
  pushDip MapDefReq
  MapDef mapDefinition <- nextDipPlain

  pushDip (Accept (MapName mapName))
    
  Start power _ _ _ <- nextDipPlain
  
  CurrentPosition scos <- nextDipPlain
  CurrentUnitPosition turn unitPoss <- nextDipPlain
  
  let gameInfo = GameInfo { gameInfoMapDef = mapDefinition
                          , gameInfoTimeout = 6 * 1000
                          , gameInfoPower = power }

  let initState = GameState { gameStateMap = MapState { supplyOwnerships = scos
                                                      , unitPositions = unitPoss }
                            , gameStateTurn = turn }

  let tout = gameInfoTimeout gameInfo  
      
  -- initialise history
  initHist <- liftMaster $ do
    f <- asksBot dipBotInitHistory
    f gameInfo initState

  liftMaster . lift . note $ "Starting main game loop"
  -- Run the main game loop
  _ <- runStateT (runGameKnowledgeT (forever (gameLoop tout))
                  gameInfo initHist
                 )
       initState
  return ()  

-- one might wonder what these are for
liftT :: (Monad m, MonadTrans t, Monad (t m)) =>
         (m a -> m b) -> t m a -> t m b
liftT f a = do
  g <- return . f =<< liftM return a
  lift g

liftT2 :: (Monad m, MonadTrans t, Monad (t m)) =>
          (m a -> m b -> m c) -> t m a -> t m b -> t m c
liftT2 f a b = do
  g <- return . f =<< liftM return a
  liftT g b

  -- we actually don't use this just wanted to see tah pattern
liftT3 :: (Monad m, MonadTrans t, Monad (t m)) =>
          (m a -> m b -> m c -> m d) -> t m a -> t m b -> t m c -> t m d
liftT3 f a b c = do
  g <- return . f =<< liftM return a
  liftT2 g b c

-- lifts be here. dont be scared just be confident
gameLoop :: Int -> GameKnowledgeT h (StateT GameState (Protocol h)) ()
gameLoop tout = do
  bot <- lift . lift . liftMaster $ askBot
  let brainMap = Map.fromList
                 [ (Spring, execBrain dipBotBrainMovement tout)
                 , (Summer, execBrain dipBotBrainRetreat tout)
                 , (Fall,   execBrain dipBotBrainMovement tout)
                 , (Autumn, execBrain dipBotBrainRetreat tout)
                 , (Winter, execBrain dipBotBrainBuild tout) ]  
  
  (GameState (MapState scos _) turn) <- lift get
  let ebrain = brainMap Map.! turnPhase turn

  -- sort so that we can do some checks on the responses
  -- TODO sanity checks on orders (all units are taken care of, validity)
  lift . lift . liftMaster . lift . note $ "Running Brain"
  moveOrders <- sort <$> ebrain
  lift . lift . liftMaster . lift . note $
    "Brain finished with " ++ show (length moveOrders) ++ " moves"
  
  lift . lift $
    -- dont submit empty order list
    when (moveOrders /= []) . pushDip $ SubmitOrder (Just turn) moveOrders
      
  liftT (const $ return ()) (return ())

  lift . lift . liftMaster . lift . note $
    "Moves submitted"
  respOrders <- (liftT . liftT) manyTry $
                [ (order, ordNote)
                | AckOrder order ordNote <- nextDip ]
  lift . lift . liftMaster . lift . note $
    "Acknowledging orders received"
  
  let sortedRespOrders = sortBy (\(o1, _) (o2, _) -> compare o1 o2) respOrders
        
  when (length moveOrders /= length sortedRespOrders) $ do
    lastMsg <- nextDip
    lift . lift . parserFail $
      "Acknowledging messages missing, last message: " ++ show lastMsg
  
  lift . lift $
    zipWithM_ (\o1 (o2, oNote) -> do
                  when (o1 /= o2) $
                    parserFail $ "Acknowledging messages don't match orders"
                  when (oNote /= MovementOK) . parserFail $
                    "Server returned \"" ++ show oNote ++
                    "\" for order \"" ++ show o1 ++ "\""
              ) moveOrders sortedRespOrders

  let missOrders = (liftT . liftT) try $ do
        Missing missing <- nextDip
        lift . lift . return . lift . lift $ do
          liftMaster . lift . note $ show missing
          parserFail $ "Missing orders, can't handle for now"
  join $ (liftT2 . liftT2) (<|>) missOrders undefined -- (return (return ()))
      
  resultOrders <- (liftT . liftT) manyTry $
                  [ (order, result)
                  | OrderResult trn order result <- nextDip
                  , _ <- when (turn /= trn) . lift . lift . parserFail $
                    "OrderResults for wrong turn (Got " ++ show trn ++
                    ", expected " ++ show turn ++ ")" ]
  
  modifyHistory $ dipBotProcessResults bot resultOrders
      
  newScos <- (liftT2 . liftT2) (<|>) -- sweeeet emooootioooon
             ((liftT . liftT) try $
              [ newScos | CurrentPosition newScos <- nextDip ])
             (return scos)
  CurrentUnitPosition newTurn newUnitPoss <- nextDip
  
  checkLost newScos newUnitPoss

  -- change state
  lift . put $ GameState { gameStateMap = MapState newScos newUnitPoss 
                         , gameStateTurn = newTurn }
  
  
    
-- |check whether we've lost
checkLost :: SupplyCOwnerships -> UnitPositions ->
             GameKnowledgeT h (StateT GameState (Protocol h)) ()
checkLost supplies (UnitPositions up) = do
  myPower <- getMyPower
  hist <- getHistory
  info <- askGameInfo
  when (isNothing (Map.lookup myPower supplies) &&
        isNothing (Map.lookup myPower up))
    . lift . lift . liftMaster $ do
    _ <- do
      gameOver <- asksBot dipBotGameOver
      runGameKnowledgeT gameOver info hist
    lift . note $ "I lost I guess? :C"
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

-- dont mind the lifts
execBrain :: (OrderClass o) => (DipBot (Master h) h -> BrainCommT o h (Master h) ()) -> Int ->
             GameKnowledgeT h (StateT GameState (Protocol h)) [Order]
execBrain botBrainFun tout = do
  gameState <- lift get
  (brainIn, brainOut) <- lift . lift . liftMaster . Master . lift $ ask -- wat
  botBrain <- lift . lift . liftMaster $ asksBot botBrainFun
  ordVar <- liftIO $ newTVarIO Nothing
  let gameKnowledge = liftM snd . flip runBrainT gameState
                      . mapBrainT (lift . liftMaster)
                      $ runBrainCommT botBrain ordVar brainIn brainOut
  morders <- runMaybeT $ do
    -- run the brain
    let earlyFinish = runGameKnowledgeTTimed tout gameKnowledge
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

