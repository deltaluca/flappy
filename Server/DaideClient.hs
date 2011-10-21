{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleContexts #-}

module DaideClient where

import DaideError
import DaideMessage

import System.IO
import System.Timeout
import System.Log.Logger
import Data.ByteString.Lazy as L
import Data.Maybe
import Data.Binary
import Control.Monad.Error
import Control.Monad.Reader
import Control.Exception as E

-- Daide communication holding client info
type DaideComm = ReaderT DaideClientInfo IO

-- DaideClient is a Daide communication with error handling
type DaideClient = ErrorT DaideError DaideComm

data DaideClientInfo = Client {clientHandle :: Handle}

runDaide = runReaderT

deserialise :: L.ByteString -> DaideClient DaideMessage
deserialise byteString = do
  ret <- liftIO . try . return . decode $ byteString
  case ret of
    Left e -> throwError (e :: DaideError)
    Right message -> return message

serialise :: MonadReader DaideClientInfo m => DaideMessage -> m L.ByteString
serialise message = return (encode message)

tellClient :: (MonadIO m, MonadReader DaideClientInfo m) => DaideMessage -> m ()
tellClient message = do
  handle <- asks clientHandle
  byteString <- serialise message
  liftIO . L.hPut handle $ byteString

askClient :: DaideClient DaideMessage
askClient = do
  handle <- asks clientHandle
  byteString <- liftIO . L.hGetContents $ handle
  deserialise byteString

askClientTimed :: Int -> DaideClient DaideMessage
askClientTimed timedelta = do
  handle <- asks clientHandle
  byteStringMaybe <- liftIO . timeout timedelta . L.hGetContents $ handle
  case byteStringMaybe of
    Nothing -> throwError TimerPopped
    Just byteString -> deserialise byteString

handleClient :: DaideComm ()
handleClient = do
  r <- runErrorT handleClient'
  case r of
    Right _ -> return ()
    Left error -> do
      liftIO . errorM "handleClient" $ "An error occured: " ++ (show error)
      tellClient (EM error)

_INITIAL_TIMEOUT = 30000000

handleClient' :: DaideClient ()
handleClient' = do
  handle <- asks clientHandle
  initialMessage <- askClientTimed _INITIAL_TIMEOUT
  case initialMessage of
    IM version -> return ()
    _ -> throwError IMNotFirst
  tellClient RM
  forever $ do
    message <- askClient
    liftIO . noticeM "handleClient" $ "Received a message: " ++ (show message)