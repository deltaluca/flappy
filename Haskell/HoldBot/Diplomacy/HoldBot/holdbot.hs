{-# LANGUAGE DeriveDataTypeable #-}

module Main where

import Diplomacy.Common.DaideHandle
import Diplomacy.Common.DaideMessage
import Diplomacy.Common.DaideError
import Diplomacy.Common.DipMessage

import Control.Monad
import Control.Monad.Error
import Control.Monad.Reader
import System.Log.Logger
import System.Console.CmdArgs
import System.Environment
import System.IO
import System.Posix
import Network
import Network.BSD

main = do
  updateGlobalLogger "Main" (setLevel NOTICE)
  opts <- getCmdlineOpts
  noticeM "Main" $ "Connecting to " ++ show (clOptsServer opts) ++
    ':' : show (clOptsPort opts)
  withSocketsDo (connectToServer (clOptsServer opts) (fromIntegral . clOptsPort $ opts))

connectToServer :: String -> PortNumber -> IO ()
connectToServer server port = do
  hndle <- connectTo server (PortNumber port)
  hSetBuffering hndle NoBuffering
  hostName <- getHostName
  runDaide communicate (Handle hndle hostName port)

communicate :: MonadDaideHandle m => m ()
communicate = do
  liftIO . noticeM "Main" $ "Connection established, sending initial message"
  tellHandle (IM (fromIntegral _DAIDE_VERSION))
  replyMessage <- askHandle
  case replyMessage of
    RM -> return ()
    _ -> throwError RMNotFirst
  forever $ do
    message <- askHandle
    handleMessage message

handleMessage :: MonadDaideHandle m => DaideMessage -> m ()
handleMessage message = do
  liftIO . print $ message

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

