{-# LANGUAGE DeriveDataTypeable, MultiParamTypeClasses, FunctionalDependencies #-}

module Diplomacy.AI.SkelBot.SkelBot (skelBot) where

import Diplomacy.Common.DaideHandle
import Diplomacy.Common.DaideMessage
import Diplomacy.Common.DaideError
import Diplomacy.Common.DipMessage
import Diplomacy.Common.Data
import Diplomacy.Common.TSeq

import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Comm
import Diplomacy.AI.SkelBot.Decision
import Diplomacy.AI.SkelBot.GameState
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

skelBot :: (Decision d) => DipBot DaideHandle d h -> IO ()
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

communicate :: (Decision d) => DipBot DaideHandle d h -> DaideHandle ()
communicate bot = do
  liftIO . noticeM "Main" $ "Connection established, sending initial message"
  tellHandle (IM (fromIntegral _DAIDE_VERSION))
  replyMessage <- askHandle
  case replyMessage of
    RM -> return ()
    _ -> throwError RMNotFirst
    
  gameInfo <- initGame

  -- Create messaging queues
  dispatcherQueue <- liftIO newTChanIO
  receiverQueue <- liftIO newTChanIO
  
  -- Create messaging threads
  hndleInfo <- ask
  liftIO . forkIO $ runDaide (dispatcher dispatcherQueue) hndleInfo
  liftIO . forkIO $ runDaide (receiver receiverQueue) hndleInfo
  
  -- create TVar for getting partial move
  decVar <- liftIO $ newTVarIO Nothing

  -- initialise history
  initHist <- dipBotInitHistory bot

  let mapDef = gameInfoMapDef gameInfo

  -- Run the main game loop
  (\loop -> runGameKnowledgeT loop gameInfo initHist) . forever $ do
    gameState <- lift getGameState
    let gameKnowledge = liftM snd . flip runBrainT gameState 
                        $ runBrainCommT (dipBotBrainComm bot) decVar receiverQueue dispatcherQueue
    decision <- runMaybeT $
                (runGameKnowledgeTTimed (gameInfoTimeout gameInfo) gameKnowledge) -- run the brain
                `mplus` (MaybeT . liftIO . atomically) (readTVar decVar) -- check TVar if timed out
    messages <- (\err -> maybe err (return . diplomise) decision) $ do -- die if no move, diplomise if there is a move
      liftIO . errorM "Main" $ "Brain timed out with no partial move"
      lift $ throwError WillDieSorry
    undefined -- mapM_ tellHandle messages   -- send the messages
      -- TODO: check negative server response here
    results <- lift getMoveResults       -- get move results
    modifyHistory (dipBotProcessResults bot results)
  return ()

-- TODO: change from TChan to TVar Seq !!! need finer control over queue (ex. brain finished but we keep getting press messages -> need to flush / signal receiver)

runGameKnowledgeTTimed :: MonadIO m => Int -> GameKnowledgeT h m (Maybe a) -> MaybeT (GameKnowledgeT h m) a
runGameKnowledgeTTimed timedelta gameKnowledge = do
  gameIO <- lift $ liftM return gameKnowledge
  m <- liftIO $ timeout timedelta gameIO
  maybe mzero (MaybeT . return) m

initGame :: DaideHandle GameInfo
initGame = undefined

getGameState :: DaideHandle GameState
getGameState = undefined

getMoveResults :: DaideHandle Results
getMoveResults = undefined

dispatcher :: OutMessageQueue -> DaideHandle ()
dispatcher q = forever $ do
  msg <- liftIO . atomically $ readTChan q
  undefined
--  tellHandle (DM (PressMessage msg))

receiver :: InMessageQueue -> DaideHandle ()
receiver q = forever $ do
  msg <- askHandle
  undefined
  -- atomically (writeTChan q msg)

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

