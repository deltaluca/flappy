{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleContexts #-}

module DaideClient where

import DaideError
import DaideMessage
import DiplomacyMessage

import System.IO
import System.Timeout
import System.Log.Logger
import Data.ByteString.Lazy as L
import Data.ByteString as S
import Data.Maybe
import Data.Binary
import Control.Monad.Error
import Control.Monad.Reader
import Control.Exception as E
import Network

-- Daide communication holding client info
type DaideCommT = ReaderT DaideClientInfo

type DaideComm = DaideCommT IO

-- DaideClient is a Daide communication with error handling
type DaideClientT m = ErrorT DaideError (DaideCommT m)

type DaideClient = DaideClientT IO

data DaideClientInfo = Client { clientHandle :: Handle
                              , clientHostName :: String
                              , clientPort :: PortNumber
                              }

class (MonadIO m, MonadReader DaideClientInfo m) => MonadDaideComm m
class (MonadDaideComm m, MonadError DaideError m) => MonadDaideClient m

instance MonadDaideComm DaideComm
instance MonadDaideComm DaideClient
instance MonadDaideClient DaideClient

runDaide = runReaderT

deserialise :: MonadDaideClient m => L.ByteString -> m DaideMessage
deserialise byteString = do
  msg <- return (decode byteString)
  ret <- liftIO . try . evaluate $ msg
  either throwError return ret

serialise :: MonadReader DaideClientInfo m => DaideMessage -> m L.ByteString
serialise message = return (encode message)

tellClient :: MonadDaideComm m => DaideMessage -> m ()
tellClient message = do
  handle <- asks clientHandle
  serialise message >>= liftIO . L.hPut handle

askClient :: MonadDaideClient m => m DaideMessage
askClient = do
  handle <- asks clientHandle
  liftIO (L.hGetContents handle) >>= deserialise

askClientTimed :: MonadDaideClient m => Int -> m DaideMessage
askClientTimed timedelta = do
  handle <- asks clientHandle
  byteString <- liftIO $ L.hGetContents handle >>= timeout timedelta . evaluate
  maybe (throwError TimerPopped) deserialise byteString

echoClient :: MonadDaideClient m => m ()
echoClient = do
  handle <- asks clientHandle
  liftIO $ L.hGetContents handle >>= L.hPut handle


handleClient :: DaideComm ()
handleClient = runErrorT handleClient' >>= handleError

handleError :: MonadDaideComm m => Either DaideError a -> m ()
handleError = flip either (const $ return ()) $ \error -> do
  liftIO . errorM "handleClient" $ "An error occured: " ++ (show error)
  tellClient (EM error)

_INITIAL_TIMEOUT = 30000000

handleClient' :: MonadDaideClient m => m ()
handleClient' = do
  initialMessage <- askClientTimed _INITIAL_TIMEOUT
  case initialMessage of
    IM version -> return ()
    _ -> throwError IMNotFirst
  tellClient RM
  forever $ do
    message <- askClient
    liftIO . print $ "COME ON"
    liftIO . print $ "Message recieved: " ++ (show message)
    handleMessage message

handleMessage :: MonadDaideClient m => DaideMessage -> m ()
handleMessage m = case m of
  IM _ -> throwError ManyIMs
  RM -> throwError RMFromClient
  DM dipMessage -> liftIO . print $ "Diplomacy Message: " ++ show dipMessage
  _ -> throwError InvalidToken
