{-# LANGUAGE GeneralizedNewtypeDeriving, FlexibleInstances, DeriveDataTypeable, MultiParamTypeClasses, FunctionalDependencies, TypeSynonymInstances, MonadComprehensions, ScopedTypeVariables #-}

-- |SkelBot is the skeleton bot that all bots build on top of. tread lightly

module Diplomacy.AI.SkelBot.SkelBot (skelBot, Master, dipMsg) where

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

-- |Master thread's monad
newtype MasterT h m a =
  Master { unMaster ::
              -- |messaging thread ids
              ReaderT (ThreadId, ThreadId)
              -- |the brain's channels for press messaging
              (ReaderT (TSeq InMessage, TSeq OutMessage)
               -- |master's channels for low level messaging with the messaging threads
               (CommT DaideMessage DaideMessage
                -- |the interface object
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

-- |the protocol monad that uses parsec as a controller monad. TStream caches messages in case we use try
newtype Protocol h a = Protocol { unProtocol :: Parsec.ParsecT (TStream DaideMessage) ()
                                                (Master h) a }
                   deriving (Functor, MonadIO, MonadPlus)

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

instance DaideNote (Master h) where
  noteWith s = lift . noteWith s

instance DaideNote (Protocol h) where
  noteWith s = liftMaster . noteWith s

type SProtocol h = GameKnowledgeT h (StateT GameState (Protocol h))

instance DaideNote (SProtocol h) where
  noteWith s = lift . lift . noteWith s

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

-- |safe shutdown
shutdownMaster :: Master h a
shutdownMaster = do
  (t1, t2) <- Master ask
  liftIO $ killThread t1
  liftIO $ killThread t2
  lift shutdownDaide

-- |gets the interface object
askBot :: Master h (DipBot (Master h) h)
askBot = Master . lift . lift . lift $ ask

asksBot :: (DipBot (Master h) h -> a) -> Master h a
asksBot f = liftM f askBot

-- |takes an interface object and returns a "main function"
skelBot :: DipBot (Master h) h -> IO ()
skelBot bot = do
  updateGlobalLogger "Main" (setLevel NOTICE)
  opts <- getCmdlineOpts
  noticeM "Main" $ "Connecting to " ++ show (clOptsServer opts) ++
    ':' : show (clOptsPort opts)
  withSocketsDo $ do
    info <- connectToServer (clOptsServer opts) (fromIntegral . clOptsPort $ opts)
    runDaideT (communicate bot) info
    hClose (socketHandle info)

connectToServer :: String -> PortNumber -> IO DaideHandleInfo
connectToServer server port = do
  hndle <- connectTo server (PortNumber port)
  hSetBuffering hndle (BlockBuffering Nothing)
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

-- |Parsec primitives for Protocol
tokenPrim a b c = Protocol $ Parsec.tokenPrim a b c
parserZero = Protocol Parsec.parserZero
parserFail = Protocol . Parsec.parserFail
--many = Protocol . Parsec.many . unProtocol

try :: Protocol h a -> Protocol h a
try = Protocol . Parsec.try . unProtocol


(<|>) :: Protocol h a -> Protocol h a -> Protocol h a
a <|> b = Protocol $ unProtocol a Parsec.<|> unProtocol b

-- |need to use try for catching protocol errors in neat pattern match failures
manyTry :: Show a => Protocol h a -> Protocol h [a]
manyTry p = unfoldM $
            (try p >>= return . Just)
            <|> (return Nothing)

-- |handler for messages that can arrive at any time
dipM :: Master h () -> (DipMessage -> Protocol h (Maybe a)) -> Protocol h a
dipM gameOver f = do
  daide <- tokenPrim show (const . const) Just
  case daide of
    IM _ -> throwEM IMFromServer
    RM -> throwEM ManyRMs
    FM -> liftMaster shutdownMaster
    EM err -> do
      liftMaster $ do
        note $ "EM : " ++ show err
        shutdownMaster
  -- put here anything that can be received at an arbitrary point in time!
             -- RESUME HERE implement shutdownMaster for shutting down queues safely
    DM dm -> case dm of
      ExitClient -> liftMaster $ pushMsg FM >> shutdownMaster
      SoloWinGame pow -> do
        note $ "Solo win: " ++ show pow
        dipMsgPlain f
      DrawGame mPowers -> do
        note $ "Draw" ++ maybe "" ((": " ++) . show) mPowers
        dipMsgPlain f
      DipError (CivilDisorder _) -> dipMsgPlain f -- it dont make no difference to me baby
      DipError err -> liftMaster $ do
        note $ "DipError: " ++ show err :: Master h ()
        pushMsg FM >> shutdownMaster
      EndGameStats turn stats -> liftMaster $ do
        gameOver
        note $ "End Game Statistics (" ++ show turn ++ "):\n" ++ show stats :: Master h ()
        pushMsg FM >> shutdownMaster
      otherMsg -> maybe parserZero return =<< f otherMsg

-- |dipMsg for Protocol
dipMsgPlain :: (DipMessage -> Protocol h (Maybe a)) -> Protocol h a
dipMsgPlain = dipM (return ())

-- |dipMsg for when we have gameknowledge context. only difference is it calls gameover hook for the brain
dipMsg :: h -> GameInfo -> (DipMessage -> Protocol h (Maybe a)) -> Protocol h a
dipMsg hist info = let gameOver = do
                         go <- asksBot dipBotGameOver
                         _ <- runGameKnowledgeT go info hist
                         return () in
                   dipM gameOver

nextDipHI :: h -> GameInfo -> Protocol h DipMessage
nextDipHI hist info = dipMsg hist info (return . Just)

nextDipPlain :: Protocol h DipMessage
nextDipPlain = dipMsgPlain (return . Just)

pushDip :: DipMessage -> Protocol h ()
pushDip msg = liftIO . atomically =<< pushMsg (DM msg)

-- |defines the high level protocol
protocol :: Protocol h ()
protocol = do
  nameMsg <- liftMaster $ liftM2 Name
             (asksBot dipBotName)
             (liftM show $
              asksBot dipBotVersion)
  pushDip nameMsg
  [() | Accept repNameMsg <- nextDipPlain, nameMsg == repNameMsg]

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

  note $ "Starting main game loop"
  -- Run the main game loop
  _ <- runStateT (runGameKnowledgeT (forever (gameLoop tout))
                  gameInfo initHist
                 )
       initState
  return ()

-- lifts be here. dont be scared just be confident
gameLoop :: Int -> SProtocol h ()
gameLoop tout = do
  hist <- getHistory
  info <- askGameInfo
  let nextDip = nextDipHI hist info
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
  note $ "Running Brain"
  moveOrders <- sort <$> ebrain
  note $ "Brain finished with " ++ show (length moveOrders) ++ " moves"

  lift . lift $ do
    -- dont submit empty order list
    when (moveOrders /= []) . pushDip $ SubmitOrder (Just turn) moveOrders

    respOrders <- manyTry $
                  [ (order, ordNote)
                  | AckOrder order ordNote <- nextDip ]

    let sortedRespOrders = sortBy (\(o1, _) (o2, _) -> compare o1 o2) respOrders

    when (length moveOrders /= length sortedRespOrders) $ do
      lastMsg <- nextDip
      parserFail $
        "Acknowledging messages missing, last message: " ++ show lastMsg

    zipWithM_ (\o1 (o2, oNote) -> do
                  when (o1 /= o2) $
                    parserFail $ "Acknowledging messages don't match orders"
                  when (oNote /= MovementOK) . parserFail $
                    "Server returned \"" ++ show oNote ++
                    "\" for order \"" ++ show o1 ++ "\""
              ) moveOrders sortedRespOrders

    let missOrders = try $ do
          Missing missing <- nextDip
          return $ do
            note $ show missing
            parserFail $ "Missing orders, can't handle for now"
    join $ missOrders <|> return (return ())

  resultOrders <- lift . lift . manyTry $
                  [ (order, result)
                  | OrderResult trn order result <- nextDip
                  , _ <- when (turn /= trn) . parserFail $
                         "OrderResults for wrong turn (Got " ++ show trn ++
                         ", expected " ++ show turn ++ ")" ]

  modifyHistory $ dipBotProcessResults bot resultOrders

  newScos <- lift . lift $ try [ newScos | CurrentPosition newScos <- nextDip ]
             <|> return scos
  CurrentUnitPosition newTurn newUnitPoss <- lift . lift $ nextDip

  checkLost newScos newUnitPoss

  -- change state
  lift . put $ GameState { gameStateMap = MapState newScos newUnitPoss
                         , gameStateTurn = newTurn }



-- |check whether we've lost
checkLost :: SupplyCOwnerships -> UnitPositions ->
             SProtocol h ()
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
             SProtocol h [Order]
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

