{-# LANGUAGE TypeSynonymInstances, MultiParamTypeClasses, FlexibleContexts, GeneralizedNewtypeDeriving #-}

module Diplomacy.Common.DaideHandle(DaideHandleT, DaideHandle,
                                    DaideAskT, DaideAsk,
                                    DaideTellT, DaideTell,
                                    DaideHandleInfo(..),
                                    MonadDaideAsk,
                                    MonadDaideTell,
                                    runDaide,
                                    runDaideAsk, runDaideTell,
                                    askDaide,
                                    askDaideTimed,
                                    tellDaide,
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

-- DaideHandle is a Daide communication with error handling
newtype DaideHandleT m a = DaideHandle { runDaideHandle :: ErrorT DaideError (DaideCommT m) a }
                         deriving (Monad, MonadIO, MonadError DaideError, MonadReader DaideHandleInfo)

instance MonadTrans DaideHandleT where
  lift = DaideHandle . lift . lift

-- |wrapper to only allow asking
newtype DaideAskT m a = DaideAsk { runDaideAsk :: DaideHandleT m a }
                      deriving (MonadTrans, Monad, MonadIO, MonadError DaideError, MonadReader DaideHandleInfo)

-- |wrapper to only allow telling
newtype DaideTellT m a = DaideTell { runDaideTell :: DaideHandleT m a }
                      deriving (MonadTrans, Monad, MonadIO, MonadError DaideError, MonadReader DaideHandleInfo)

type DaideHandle = DaideHandleT IO
type DaideAsk = DaideAskT IO
type DaideTell = DaideTellT IO

data DaideHandleInfo = Handle { socketHandle :: Handle
                              , hostName :: String
                              , hostPort :: PortNumber
                              }
                     deriving (Show)

class MonadDaideTell m where
  tellDaide :: DaideMessage -> m ()

class MonadDaideAsk m where
  askDaide :: m DaideMessage
  askDaideTimed :: Int -> m DaideMessage

instance (MonadIO m) => MonadDaideTell (DaideTellT m) where
  tellDaide = DaideTell . DaideHandle . lift . tellDaide

instance (MonadIO m) => MonadDaideTell (DaideCommT m) where
  tellDaide message = do
    hndle <- asks socketHandle
    liftIO . L.hPut hndle =<< serialise message

instance (MonadIO m) => MonadDaideAsk (DaideAskT m) where
  askDaide = DaideAsk $ do
    hndle <- asks socketHandle
    contents <- liftIO (L.hGetContents hndle)
    return =<< deserialise contents

  askDaideTimed timedelta = DaideAsk $ do
    hndle <- asks socketHandle
    byteString <- liftIO $ L.hGetContents hndle >>= timeout timedelta . evaluate
    maybe (throwError TimerPopped) deserialise byteString

noteWith :: (MonadIO m, MonadReader DaideHandleInfo m) => (String -> String -> IO ()) -> String -> m ()
noteWith f msg = do
  name <- asks hostName
  port <- asks hostPort
  time <- liftIO getCurrentTime
  liftIO . f "Main" $ show time ++ " [" ++ name ++ " : " ++ show port ++ "] " ++ msg

note :: (MonadIO m, MonadReader DaideHandleInfo m) => String -> m ()
note = noteWith noticeM

runDaide :: DaideHandle a -> DaideHandleInfo -> IO ()
runDaide daide info = runReaderT (runErrorT (runDaideHandle daide) >>= handleError) info

handleError :: (MonadIO m, MonadDaideTell m, MonadReader DaideHandleInfo m) => Either DaideError a -> m ()
handleError = flip either (const $ return ()) $ \err -> do
  noteWith errorM $ "An error occured: " ++ (show err)
  tellDaide (EM err)

deserialise :: MonadIO m => L.ByteString -> DaideHandleT m DaideMessage
deserialise byteString = do
  msg <- return (decode byteString)
  ret <- liftIO . try . evaluate $ msg
  either throwError return ret

serialise :: MonadReader DaideHandleInfo m => DaideMessage -> m L.ByteString
serialise message = return (encode message)

echoHandle :: MonadIO m => DaideHandleT m ()
echoHandle = do
  hndle <- asks socketHandle
  liftIO $ L.hGetContents hndle >>= L.hPut hndle

