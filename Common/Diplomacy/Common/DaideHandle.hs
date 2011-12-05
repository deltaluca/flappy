{-# LANGUAGE TypeSynonymInstances, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, GeneralizedNewtypeDeriving #-}

module Diplomacy.Common.DaideHandle(DaideHandleT, DaideHandle,
                                    DaideAskT, DaideAsk,
                                    DaideTellT, DaideTell,
                                    DaideHandleInfo(..),
                                    MonadDaideAsk,
                                    MonadDaideTell,
                                    runDaideT,
                                    runDaideAsk, runDaideTell,
                                    askDaide,
                                    askDaideTimed,
                                    tellDaide,
                                    note, noteWith,
                                    shutdownDaide,
                                    shutdownDaideAsk,
                                    shutdownDaideTell,
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
import Control.Monad.Cont
import Control.Exception as E
import Network

-- Daide communication holding client info
type DaideCommT = ReaderT DaideHandleInfo

-- DaideHandle is a Daide communication with error handling and exiting
newtype DaideHandleT m a = DaideHandle
                           { runDaideHandle :: ErrorT (Maybe DaideError) (DaideCommT m) a }
                         deriving ( Monad, MonadIO, MonadReader DaideHandleInfo, MonadError (Maybe DaideError))

instance MonadTrans DaideHandleT where
  lift = DaideHandle . lift . lift

-- |wrapper to only allow asking
newtype DaideAskT m a = DaideAsk { runDaideAsk :: DaideHandleT m a }
                      deriving ( MonadTrans, Monad, MonadIO, MonadError (Maybe DaideError)
                               , MonadReader DaideHandleInfo)

-- |wrapper to only allow telling
newtype DaideTellT m a = DaideTell { runDaideTell :: DaideHandleT m a }
                      deriving ( MonadTrans, Monad, MonadIO, MonadError (Maybe DaideError)
                               , MonadReader DaideHandleInfo)

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
    maybe (throwEM TimerPopped) deserialise byteString

instance (MonadIO m) => DaideErrorClass (DaideHandleT m) where
  throwEM = throwError . Just

instance (MonadIO m) => DaideErrorClass (DaideTellT m) where
  throwEM = DaideTell . throwEM

instance (MonadIO m) => DaideErrorClass (DaideAskT m) where
  throwEM = DaideAsk . throwEM

noteWith :: (MonadIO m, MonadReader DaideHandleInfo m) => (String -> String -> IO ()) -> String -> m ()
noteWith f msg = do
  name <- asks hostName
  port <- asks hostPort
  time <- liftIO getCurrentTime
  liftIO . f "Main" $ show time ++ " [" ++ name ++ " : " ++ show port ++ "] " ++ msg

note :: (MonadIO m, MonadReader DaideHandleInfo m) => String -> m ()
note = noteWith noticeM

runDaideT :: (MonadIO m) => DaideHandleT m () -> DaideHandleInfo -> m ()
runDaideT daide info =
  runReaderT (runErrorT (runDaideHandle daide) >>= handleError) info

shutdownDaide :: (MonadIO m) => DaideHandleT m ()
shutdownDaide = throwError Nothing

shutdownDaideAsk :: (MonadIO m) => DaideAskT m ()
shutdownDaideAsk = DaideAsk shutdownDaide

shutdownDaideTell :: (MonadIO m) => DaideTellT m ()
shutdownDaideTell = DaideTell shutdownDaide

handleError :: (MonadIO m, MonadDaideTell m, MonadReader DaideHandleInfo m) => Either (Maybe DaideError) a -> m ()
handleError = flip either (const $ return ()) . maybe (return ()) $  -- if Nothing it was a clean shutdown
              \err -> do        -- otherwise print and signal the other party
                noteWith errorM $ "An error occured: " ++ (show err)
                tellDaide (EM err)

deserialise :: (MonadIO m) => L.ByteString -> DaideHandleT m DaideMessage
deserialise byteString = do
  msg <- return (decode byteString)
  ret <- liftIO . try . evaluate $ msg
  either throwError return ret

serialise :: (MonadReader DaideHandleInfo m) => DaideMessage -> m L.ByteString
serialise message = return (encode message)

echoHandle :: (MonadIO m) => DaideHandleT m ()
echoHandle = do
  hndle <- asks socketHandle
  liftIO $ L.hGetContents hndle >>= L.hPut hndle

