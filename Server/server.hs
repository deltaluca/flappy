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
  withSocketsDo . listenForClients . serverPort $ opts


listenForClients port =  do
  socket <- listenOn (PortNumber . fromIntegral $ serverPort opts)
  forever $ do
    (handle, hostName, clientPort) <- accept socket
    noticeM "Main" $ "Client " ++ hostName ++
      ":" ++ show clientPort ++ " connecting..."
    hSetBuffering handle NoBuffering
    forkIO $ handleClient (Client handle)
  


handleClient :: DiplomacyMap -> Handle -> IO ()
handleClient map handle = do
  initialMessage <- timeout _INITIAL_TIMEOUT (L.hGetContents handle)
  maybe
    (tellError handle TimerPopped)
    (handleInitialMessage handle)
    initialMessage

handleInitialMessage :: Handle -> L.ByteString -> IO ()
handleInitialMessage handle message =
  E.catch (do
              initialMessage <- return . daideDeserialise $ message
              case initialMessage of
                IM _ -> tell handle RM
                _ -> tellError handle UnknownMessage
          ) (\e -> case e of
                WrongMagicNumber _ -> tellError handle WrongMagic)
    

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
