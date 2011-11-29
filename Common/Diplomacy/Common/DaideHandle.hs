{-# LANGUAGE TypeSynonymInstances, MultiParamTypeClasses, FlexibleContexts, GeneralizedNewtypeDeriving #-}

module Diplomacy.Common.DaideHandle(DaideHandleT, DaideHandle,
                                    DaideCommT, DaideComm,
                                    DaideHandleInfo(..),
                                    MonadDaideComm,
                                    MonadDaideHandle,
                                    runDaide,
                                    askHandle,
                                    askHandleTimed,
                                    tellHandle,
                                    note, noteWith,
                                    echoHandle) where

import Diplomacy.Common.DaideError
import Diplomacy.Common.DaideMessage

import System.IO
import System.Timeout
import System.Log.Logger
import Data.ByteString.Lazy as L
import Data.Binary
import Data.Time.Clock
import Control.Monad.Error
import Control.Monad.Reader
import Control.Monad.Trans
import Control.Exception as E
import Network

-- Daide communication holding client info
type DaideCommT = ReaderT DaideHandleInfo

type DaideComm = DaideCommT IO

-- DaideHandle is a Daide communication with error handling
newtype DaideHandleT m a = DaideHandle { runDaideHandle :: ErrorT DaideError (DaideCommT m) a }
                         deriving (Monad, MonadIO, MonadError DaideError, MonadReader DaideHandleInfo)

instance MonadTrans DaideHandleT where
  lift = DaideHandle . lift . lift

-- |wrapper to only allow asking
newtype DaideAskT m a = DaideAsk { runDaideAsk :: DaideHandleT m a }
                      deriving (MonadTrans, Monad, MonadIO, MonadError DaideError)

-- |wrapper to only allow telling
newtype DaideTellT m a = DaideTell { runDaideTell :: DaideHandleT m a }
                      deriving (MonadTrans, Monad, MonadIO, MonadError DaideError)

type DaideHandle = DaideHandleT IO

data DaideHandleInfo = Handle { socketHandle :: Handle
                              , hostName :: String
                              , hostPort :: PortNumber
                              }
                     deriving (Show)

class MonadDaideTell m where
  tellDaide :: DaideMessage -> m ()

class MonadDaideAsk m where
  askDaide :: m DaideMesage
  askDaideTimed :: Int -> m DaideMessage

askDaide :: MonadIO m => DaideAskT m DaideMessage
askDaide = DaideAsk askHandle

askDaideTimed :: MonadIO m => Int -> DaideAskT m DaideMessage
askDaideTimed = DaideAsk . askHandleTimed

tellDaide :: MonadIO m => DaideMessage -> DaideTellT m ()
tellDaide = DaideAsk . tellHandle


noteWith :: MonadIO m => (String -> String -> IO ()) -> String -> DaideHandleT m ()
noteWith f msg = do
  name <- asks hostName
  port <- asks hostPort
  time <- liftIO getCurrentTime
  liftIO . f "Main" $ show time ++ " [" ++ name ++ " : " ++ show port ++ "] " ++ msg

note :: String -> DaideHandle ()
note = noteWith noticeM

runDaide :: DaideHandle a -> DaideHandleInfo -> IO ()
runDaide (DaideHandle daide) info = runReaderT (runErrorT daide >>= handleError) info

handleError :: (MonadIO m, MonadDaideComm m) => Either DaideError a -> DaideHandleT m ()
handleError = flip either (const $ return ()) $ \err -> do
  noteWith errorM $ "An error occured: " ++ (show err)
  tellHandle (EM err)

deserialise :: MonadIO m => L.ByteString -> DaideHandleT m DaideMessage
deserialise byteString = do
  msg <- return (decode byteString)
  ret <- liftIO . try . evaluate $ msg
  either throwError return ret

serialise :: MonadReader DaideHandleInfo m => DaideMessage -> m L.ByteString
serialise message = return (encode message)

instance (MonadIO m) => MonadDaideTell (DaideHandleT m) where
  tellHandle message = do
    hndle <- asks socketHandle
    liftIO . L.hPut hndle =<< serialise message

askHandle :: MonadIO m => DaideHandleT m DaideMessage
askHandle = do
  hndle <- asks socketHandle
  contents <- liftIO (L.hGetContents hndle)
  return =<< deserialise contents

askHandleTimed :: MonadIO m => Int -> DaideHandleT m DaideMessage
askHandleTimed timedelta = do
  hndle <- asks socketHandle
  byteString <- liftIO $ L.hGetContents hndle >>= timeout timedelta . evaluate
  maybe (throwError TimerPopped) deserialise byteString

echoHandle :: MonadIO m => DaideHandleT m ()
echoHandle = do
  hndle <- asks socketHandle
  liftIO $ L.hGetContents hndle >>= L.hPut hndle

