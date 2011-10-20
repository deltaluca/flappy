{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module DaideClient where

import Serial

import System.IO
import System.Timeout
import Data.ByteString.Lazy as L
import Data.Maybe
import Control.Monad.Error
import Control.Monad.Reader

-- Daide communication holding client info
type DaideComm = ReaderT DaideClientInfo IO

-- DaideClient is a Daide communication with error handling
type DaideClient = ErrorT DaideError DaideComm

data DaideClientInfo = Client {clientHandle :: Handle}

tell :: DaideMessage -> DaideComm ()
tell message = do
  handle <- asks clientHandle
  liftIO . L.hPut handle . daideSerialise $ message

askClientIO :: Handle -> IO DaideMessage
askClientIO handle = do
  byteString <- liftIO . L.hGetContents $ handle
  return (daideDeserialise byteString)

askClient :: DaideClient DaideMessage
askClient = do
  handle <- asks clientHandle
  liftIO (askClientIO handle)

handleClient :: DaideClientInfo -> DaideComm ()
handleClient info = do
  r <- runErrorT handleClient'
  case r of
    Right _ -> return ()
    Left error -> tell (EM error)

_INITIAL_TIMEOUT = 30000000

handleClient' :: DaideClient ()
handleClient' = do
  handle <- asks clientHandle
  initialMessage <- liftIO $ timeout _INITIAL_TIMEOUT (askClientIO handle)
  when (isNothing initialMessage) (throwError TimerPopped)
  lift (tell RM)