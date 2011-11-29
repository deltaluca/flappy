{-# LANGUAGE DeriveDataTypeable #-}

module Main where

import Diplomacy.Common.DaideHandle
import Diplomacy.Common.DipMessage
import Diplomacy.Common.DaideMessage
import Diplomacy.Common.DaideError

import Diplomacy.Server.Client

import Control.Monad
import Control.Monad.Error
import Control.Concurrent
import System.Environment
import System.IO
import Network
import System.Console.CmdArgs
import System.Log.Logger

import qualified Data.ByteString as BS

main = do
  updateGlobalLogger "Main" (setLevel NOTICE)
  opts <- getCmdlineOpts
  noticeM "Main" $ "Starting server with map file \"" ++
    clOptsMap opts ++ "\" on port " ++ show (clOptsPort opts)
  -- gameMap <- parseMap (mapFile opts)
  withSocketsDo . listenForClients . PortNumber . fromIntegral $ (clOptsPort opts)

listenForClients :: PortID -> IO ()
listenForClients serverPort = do
  socket <- listenOn serverPort
  forever $ do
    (hndle, hostName, port) <- accept socket
    noticeM "Main" $ "Client " ++ hostName ++
      ":" ++ show port ++ " connecting..."
    hSetBuffering hndle NoBuffering
    forkIO $ runDaide handleClient (Handle hndle hostName port) 

-- map
data DiplomacyMap = Map
                  deriving (Show)


parseMap :: String -> IO DiplomacyMap
parseMap mapName = do
  handle <- openFile mapName ReadMode
  contents <- BS.hGetContents handle
  e <- runErrorT (parseDipMessage 10 contents)
  either print print e
  return Map


-- command line options
data CLOpts = CLOptions
              { clOptsPort :: Int
              , clOptsMap :: String
              } deriving (Data, Typeable, Show)


getCmdlineOpts = do  
  progName <- getProgName
  cmdArgs $ CLOptions 
       { clOptsPort = 1234      &= argPos 0 &= typ "PORT"
       , clOptsMap = "defMap.map" &= argPos 1 &= typ "FILE"
       }
       &= program progName
       &= summary "Flappy AI server 0.1"
