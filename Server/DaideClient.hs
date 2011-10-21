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
import Data.ByteString as S
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
  msg <- return $ decode byteString
  ret <- liftIO . try . evaluate $ msg
  case ret of
    Left e -> throwError e
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
  byteString <- liftIO $ L.hGetContents handle
  byteStringMaybe <- liftIO . timeout timedelta . evaluate $ byteString 
  case byteStringMaybe of
    Nothing -> throwError TimerPopped
    Just byteStr -> deserialise byteString

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
    liftIO . print $ "Message recieved: " ++ (show message)