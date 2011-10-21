{-# LANGUAGE DeriveDataTypeable #-}

module Main where

import Control.Monad
import Control.Monad.Trans
import Control.Exception as E
import Control.Concurrent
import System.IO
import System
import System.Console.GetOpt
import Network
import Maybe
import System.Console.CmdArgs
import System.Log.Logger
import Data.ByteString.Lazy as L
import Data.Maybe

import DaideClient

main = do
  updateGlobalLogger "Main" (setLevel DEBUG)
  opts <- getCmdlineOpts
  noticeM "Main" $ "Starting server with map file \"" ++
    mapFile opts ++ "\" on port " ++ show (serverPort opts)
  gameMap <- parseMap (mapFile opts)
  withSocketsDo . listenForClients $ serverPort opts

listenForClients :: Int -> IO ()
listenForClients port = do
  socket <- listenOn (PortNumber . fromIntegral $ port)
  forever $ do
    (handle, hostName, clientPort) <- accept socket
    noticeM "Main" $ "Client " ++ hostName ++
      ":" ++ show clientPort ++ " connecting..."
    hSetBuffering handle NoBuffering
    forkIO $ runDaide handleClient (Client handle) 

-- map
data DiplomacyMap = Map
                  deriving (Show)


parseMap :: String -> IO DiplomacyMap
parseMap mapFile = return Map

-- command line options
data CLOpts = CLOptions
              { serverPort :: Int
              , mapFile :: String
              } deriving (Data, Typeable, Show)


getCmdlineOpts = do  
  progName <- getProgName
  cmdArgs $ CLOptions 
       { serverPort = 1234      &= argPos 0 &= typ "PORT"
       , mapFile = "defMap.map" &= argPos 1 &= typ "FILE"
       }
       &= program progName
       &= summary "Flappy AI server 0.1"
