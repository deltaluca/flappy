{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleContexts #-}

module Diplomacy.Common.DaideHandle where

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

data DaideHandleInfo = Handle { clientHandle :: Handle
                              , clientHostName :: String
                              , clientPort :: PortNumber
                              }

class (MonadIO m, MonadReader DaideHandleInfo m) => MonadDaideComm m
class (MonadDaideComm m, MonadError DaideError m) => MonadDaideHandle m

instance MonadDaideComm DaideComm
instance MonadDaideComm DaideHandle
instance MonadDaideHandle DaideHandle

runDaide = runReaderT

deserialise :: MonadDaideHandle m => L.ByteString -> m DaideMessage
deserialise byteString = do
  msg <- return (decode byteString)
  ret <- liftIO . try . evaluate $ msg
  either throwError return ret

serialise :: MonadReader DaideHandleInfo m => DaideMessage -> m L.ByteString
serialise message = return (encode message)

tellHandle :: MonadDaideComm m => DaideMessage -> m ()
tellHandle message = do
  hndle <- asks clientHandle
  serialise message >>= liftIO . L.hPut hndle

askHandle :: MonadDaideHandle m => m DaideMessage
askHandle = do
  hndle <- asks clientHandle
  liftIO (L.hGetContents hndle) >>= deserialise

askHandleTimed :: MonadDaideHandle m => Int -> m DaideMessage
askHandleTimed timedelta = do
  hndle <- asks clientHandle
  byteString <- liftIO $ L.hGetContents hndle >>= timeout timedelta . evaluate
  maybe (throwError TimerPopped) deserialise byteString

echoClient :: MonadDaideHandle m => m ()
echoClient = do
  hndle <- asks clientHandle
  liftIO $ L.hGetContents hndle >>= L.hPut hndle


handleClient :: DaideComm ()
handleClient = runErrorT handleClient' >>= handleError

handleError :: MonadDaideComm m => Either DaideError a -> m ()
handleError = flip either (const $ return ()) $ \err -> do
  liftIO . errorM "handleClient" $ "An error occured: " ++ (show err)
  tellHandle (EM err)

_INITIAL_TIMEOUT = 30000000

handleClient' :: MonadDaideHandle m => m ()
handleClient' = do
  initialMessage <- askHandleTimed _INITIAL_TIMEOUT
  case initialMessage of
    IM _ -> return ()
    _ -> throwError IMNotFirst
  tellHandle RM
  forever $ do
    message <- askHandle
    liftIO . print $ "COME ON"
    liftIO . print $ "Message recieved: " ++ (show message)
    handleMessage message

handleMessage :: MonadDaideHandle m => DaideMessage -> m ()
handleMessage m = case m of
  IM _ -> throwError ManyIMs
  RM -> throwError RMFromClient
  DM dipMessage -> liftIO . print $ "Diplomacy Message: " ++ show dipMessage
  _ -> throwError InvalidToken
