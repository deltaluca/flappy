{-# LANGUAGE DeriveDataTypeable #-}

module Diplomacy.AI.SkelBot.SkelBot (skelBot) where

import Diplomacy.Common.DaideHandle
import Diplomacy.Common.DaideMessage
import Diplomacy.Common.DaideError
import Diplomacy.Common.DipMessage

import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.DipBot
import Diplomacy.AI.SkelBot.Comm
import Diplomacy.AI.SkelBot.Decision

import Control.Monad
import Control.Monad.Error
import Control.Monad.Reader
import Control.Concurrent.STM
import Control.Concurrent
import System.Log.Logger
import System.Console.CmdArgs
import System.Environment
import System.IO
import System.Posix
import Network
import Network.BSD

data GameInfo = GameInfo { gameInfoMapDef :: MapDefinition }

skelBot :: (Decision d) => DipBot d h -> IO ()
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

communicate :: Decision d => DipBot d h -> DaideHandle ()
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
  forkIO (runDaide (dispatcher dispatcherQueue) hndleInfo)
  forkIO (runDaide (receiver receiverQueue) hndleInfo)
  
    -- Run the brain
  -- (((), dec), ) <- liftIO . flip runCommT (receiverQueue, dispatcherQueue)
  -- . flip runGameKnowledgeT mapDef

initGame :: DaideHandle GameInfo
initGame = undefined

dispatcher :: OutMessageQueue -> DaideHandle ()
dispatcher q = forever $ do
  msg <- atomically (readTChan q)
  tellHandle (DM (PressMessage msg))

receiver :: InMessageQueue -> DaideHandle ()
receiver = forever $ do
  msg <- askHandle
  atomically (writeTChan q msg)

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

