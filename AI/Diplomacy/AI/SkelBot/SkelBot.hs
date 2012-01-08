{-# LANGUAGE GeneralizedNewtypeDeriving, FlexibleInstances, DeriveDataTypeable, MultiParamTypeClasses, FunctionalDependencies, TypeSynonymInstances, MonadComprehensions #-}

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
newtype MasterT m a = Master { unMaster :: (ReaderT (ThreadId, ThreadId) -- for shutting down
                                            (ReaderT (TSeq InMessage, TSeq OutMessage)
                                             (CommT DaideMessage DaideMessage m)) a)}
                    deriving (Functor, Monad, MonadIO, MonadReader (ThreadId, ThreadId))

type Master = MasterT DaideHandle

instance MonadTrans MasterT where
  lift = Master . lift . lift . lift

instance (Monad m) => MonadComm DaideMessage DaideMessage (MasterT m) where
  pushMsg = Master . lift . lift . pushMsg
  popMsg = Master . lift . lift $ popMsg
  peekMsg = Master . lift . lift $ peekMsg
  pushBackMsg = Master . lift . lift . pushBackMsg

instance DaideErrorClass (MasterT DaideHandle) where
  throwEM = Master . lift . lift . lift . throwEM

newtype Protocol a = Protocol { unProtocol :: Parsec.ParsecT (TStream DaideMessage) () Master a }
                   deriving (Functor, MonadIO)

instance Monad Protocol where
  return = Protocol . return
  ma >>= f = Protocol $ unProtocol ma >>= unProtocol . f
  fail = Protocol . Parsec.parserFail

instance MonadComm DaideMessage DaideMessage Protocol where
  pushMsg = Protocol . lift . pushMsg
  popMsg = Protocol . lift $ popMsg
  peekMsg = Protocol . lift $ peekMsg
  pushBackMsg = Protocol . lift . pushBackMsg
  
instance DaideErrorClass Protocol where
  throwEM = liftMaster . throwEM

liftMaster :: Master a -> Protocol a
liftMaster = Protocol . lift

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
  hostNam <- getHostName
  return (Handle hndle hostNam port)

communicate :: DipBot Master h -> DaideHandle ()
communicate bot = do
  note "Connection established, sending initial message"
  runDaideTell $ tellDaide (IM (fromIntegral _DAIDE_VERSION))
  replyMessage <- runDaideAsk askDaide
  case replyMessage of
    RM -> return ()
    _ -> throwEM RMNotFirst

  runMaster (runProtocol (protocol bot))

  return ()

runProtocol :: Protocol a -> Master a
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

manyTry :: Protocol a -> Protocol [a]
manyTry p = unfoldM ((try p >>= return . Just) <|> return Nothing)

dipMsg :: (DipMessage -> Protocol (Maybe a)) -> Protocol a
dipMsg f = do
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
        dipMsg f
      DrawGame mPowers -> do
        liftMaster . lift . note $ "Draw" ++ maybe "" ((": " ++) . show) mPowers
        dipMsg f
      DipError (CivilDisorder _) -> dipMsg f -- it dont make no difference to me baby
      DipError err -> liftMaster $ do
        lift . note $ "DipError: " ++ show err
        pushMsg FM >> shutdownMaster
      EndGameStats turn stats -> liftMaster $ do
        lift . note $ "End Game Statistics (" ++ show turn ++ "):\n" ++ show stats
        pushMsg FM >> shutdownMaster
      otherMsg -> maybe parserZero return =<< f otherMsg

dipMsg1 :: DipMessage -> Protocol DipMessage
dipMsg1 msg = dipMsg (\rmsg -> return $ if rmsg == msg
                                        then Just msg
                                        else Nothing)

nextDip :: Protocol DipMessage
nextDip = dipMsg (return . Just)

pushDip :: DipMessage -> Protocol ()
pushDip msg = liftIO . atomically =<< pushMsg (DM msg)


protocol :: DipBot Master h -> Protocol ()
protocol bot = do
  let nameMsg = Name (dipBotName bot) (show $ dipBotVersion bot)
  pushDip nameMsg  
  dipMsg1 (Accept nameMsg)

  MapName mapName <- nextDip

  -- BOTTLENECK (?) always request mapdefinition
  pushDip MapDefReq
  MapDef mapDefinition <- nextDip

  pushDip (Accept (MapName mapName))
    
  Start power _ _ _ <- nextDip
  
  CurrentPosition scos <- nextDip
  CurrentUnitPosition turn unitPoss <- nextDip
  
  let gameInfo = GameInfo { gameInfoMapDef = mapDefinition
                          , gameInfoTimeout = 6 * 1000
                          , gameInfoPower = power }

  let initState = GameState { gameStateMap = MapState { supplyOwnerships = scos
                                                      , unitPositions = unitPoss }
                            , gameStateTurn = turn }

  let tout = gameInfoTimeout gameInfo  
      
  -- initialise history
  initHist <- liftMaster $ dipBotInitHistory bot gameInfo initState

  liftMaster . lift . note $ "Starting main game loop"
  -- Run the main game loop
  _ <- runStateT (runGameKnowledgeT (forever (gameLoop bot tout))
                  gameInfo initHist
                 )
       initState
  return ()  

gameLoop :: DipBot Master h -> Int -> GameKnowledgeT h (StateT GameState Protocol) ()
gameLoop bot tout = do
  let brainMap = Map.fromList
                 [ (Spring, execBrain (dipBotBrainMovement bot) tout)
                 , (Summer, execBrain (dipBotBrainRetreat bot) tout)
                 , (Fall,   execBrain (dipBotBrainMovement bot) tout)
                 , (Autumn, execBrain (dipBotBrainRetreat bot) tout)
                 , (Winter, execBrain (dipBotBrainBuild bot) tout) ]  
  
  (GameState (MapState scos _) turn) <- lift get
  let ebrain = brainMap Map.! turnPhase turn

  -- sort so that we can do some checks on the responses
  -- TODO sanity checks on orders (all units are taken care of, validity)
  lift . lift . liftMaster . lift . note $ "Running Brain"
  moveOrders <- sort <$> ebrain
  lift . lift . liftMaster . lift . note $
    "Brain finished with " ++ show (length moveOrders) ++ " moves"
  
  lift . lift $ do            -- not concerned with history/gamestate yet
    -- dont submit empty order list
    when (moveOrders /= []) . pushDip $ SubmitOrder (Just turn) moveOrders
      
    respOrders <- manyTry [ (order, ordNote)
                          | AckOrder order ordNote <- nextDip ]
    let sortedRespOrders = sortBy (\(o1, _) (o2, _) -> compare o1 o2) respOrders
        
    when (length moveOrders /= length sortedRespOrders) $ do
      lastMsg <- nextDip
      parserFail $ "Acknowledging messages missing, last message: " ++ show lastMsg
  
    zipWithM_ (\o1 (o2, oNote) -> do
                  when (o1 /= o2) $
                    parserFail $ "Acknowledging messages don't match orders"
                  when (oNote /= MovementOK) . parserFail $
                    "Server returned \"" ++ show oNote ++
                    "\" for order \"" ++ show o1 ++ "\""
              ) moveOrders sortedRespOrders

    join $ (try $ do
               Missing missing <- nextDip
               return $ do
                 liftMaster . lift . note $ show missing
                 parserFail $ "Missing orders, can't handle for now"
           ) <|>
      return (return ())
      
  resultOrders <- lift . lift . manyTry $
                  [ (order, result)
                  | OrderResult trn order result <- nextDip
                  , _ <- when (turn /= trn) . parserFail $
                    "OrderResults for wrong turn (Got " ++ show trn ++
                    ", expected " ++ show turn ++ ")" ]
  
  modifyHistory (dipBotProcessResults bot resultOrders)  
      
  newScos <- lift . lift $ try [ newScos | CurrentPosition newScos <- nextDip ] <|> return scos
  CurrentUnitPosition newTurn newUnitPoss <- lift . lift $ nextDip
  
  checkLost newScos newUnitPoss

  -- change state
  lift . put $ GameState { gameStateMap = MapState newScos newUnitPoss 
                         , gameStateTurn = newTurn }
  
  
    
-- |check whether we've lost
checkLost :: SupplyCOwnerships -> UnitPositions ->
             GameKnowledgeT h (StateT GameState Protocol) ()
checkLost supplies (UnitPositions up) = do
  myPower <- getMyPower
  when (isNothing (Map.lookup myPower supplies) &&
        isNothing (Map.lookup myPower up))
    . lift . lift . liftMaster $ do
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

-- dont mind the lifts
execBrain :: (OrderClass o) => BrainCommT o h Master () -> Int ->
             GameKnowledgeT h (StateT GameState Protocol) [Order]
execBrain botBrain tout = do
  gameState <- lift get
  (brainIn, brainOut) <- lift . lift . liftMaster . Master . lift $ ask -- wat
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

