{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleContexts #-}

module Diplomacy.Common.DaideHandle(DaideHandleT, DaideHandle,
                                    DaideCommT, DaideComm,
                                    DaideHandleInfo(..),
                                    MonadDaideComm,
                                    MonadDaideHandle,
                                    runDaide,
                                    askHandle,
                                    askHandleTimed,
                                    tellHandle,
                                    echoHandle) where

import Diplomacy.Common.DaideError
import Diplomacy.Common.DaideMessage

import System.IO
import System.Timeout
import System.Log.Logger
import Data.ByteString.Lazy as L
import Data.Binary
import Control.Monad.Error
import Control.Monad.Reader
import Control.Exception as E
import Network

-- Daide communication holding client info
type DaideCommT = ReaderT DaideHandleInfo

type DaideComm = DaideCommT IO

-- DaideHandle is a Daide communication with error handling
type DaideHandleT m = ErrorT DaideError (DaideCommT m)

type DaideHandle = DaideHandleT IO

data DaideHandleInfo = Handle { socketHandle :: Handle
                              , hostName :: String
                              , hostPort :: PortNumber
                              }

class (MonadIO m, MonadReader DaideHandleInfo m) => MonadDaideComm m
class (MonadDaideComm m, MonadError DaideError m) => MonadDaideHandle m

instance MonadDaideComm DaideComm
instance MonadDaideComm DaideHandle
instance MonadDaideHandle DaideHandle

runDaide :: DaideHandle a -> DaideHandleInfo -> IO ()
runDaide daide info = runReaderT (runErrorT daide >>= handleError) info

handleError :: MonadDaideComm m => Either DaideError a -> m ()
handleError = flip either (const $ return ()) $ \err -> do
  liftIO . errorM "runDaide" $ "An error occured: " ++ (show err)
  tellHandle (EM err)

deserialise :: MonadDaideHandle m => L.ByteString -> m DaideMessage
deserialise byteString = do
  msg <- return (decode byteString)
  ret <- liftIO . try . evaluate $ msg
  either throwError return ret

serialise :: MonadReader DaideHandleInfo m => DaideMessage -> m L.ByteString
serialise message = return (encode message)

tellHandle :: MonadDaideComm m => DaideMessage -> m ()
tellHandle message = do
  hndle <- asks socketHandle
  serialise message >>= liftIO . L.hPut hndle

askHandle :: MonadDaideHandle m => m DaideMessage
askHandle = do
  hndle <- asks socketHandle
  liftIO (L.hGetContents hndle) >>= deserialise

askHandleTimed :: MonadDaideHandle m => Int -> m DaideMessage
askHandleTimed timedelta = do
  hndle <- asks socketHandle
  byteString <- liftIO $ L.hGetContents hndle >>= timeout timedelta . evaluate
  maybe (throwError TimerPopped) deserialise byteString

echoHandle :: MonadDaideHandle m => m ()
echoHandle = do
  hndle <- asks socketHandle
  liftIO $ L.hGetContents hndle >>= L.hPut hndle
