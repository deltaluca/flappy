{-# LANGUAGE TypeSynonymInstances, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, GeneralizedNewtypeDeriving #-}

module Diplomacy.Common.DaideHandle(DaideHandleT, DaideHandle,
                                    DaideAskT, DaideAsk,
                                    DaideTellT, DaideTell,
                                    DaideHandleInfo(..),
                                    MonadDaideAsk,
                                    MonadDaideTell,
                                    DaideErrorClass,
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
import Data.Serialize
import Data.Time.Clock
import Control.DeepSeq
import Control.Monad.Error
import Control.Monad.Reader
import Control.Monad.Trans
import Control.Monad.Cont
import Control.Exception as E
import Network

import qualified Control.Monad.State as State

-- Daide communication holding client info
type DaideCommT m = State.StateT L.ByteString (ReaderT DaideHandleInfo m)

-- DaideHandle is a Daide communication with error handling and exiting
newtype DaideHandleT m a = DaideHandle
                           { runDaideHandle :: ErrorT (Maybe DaideError) (DaideCommT m) a }
                         deriving ( Functor, Monad, MonadIO, MonadReader DaideHandleInfo
                                  , MonadError (Maybe DaideError), State.MonadState L.ByteString)

instance MonadTrans DaideHandleT where
  lift = DaideHandle . lift . lift . lift

-- |wrapper to only allow asking
newtype DaideAskT m a = DaideAsk { runDaideAsk :: DaideHandleT m a }
                      deriving ( MonadTrans, Monad, MonadIO, MonadError (Maybe DaideError)
                               , MonadReader DaideHandleInfo, State.MonadState L.ByteString)

-- |wrapper to only allow telling
newtype DaideTellT m a = DaideTell { runDaideTell :: DaideHandleT m a }
                      deriving ( MonadTrans, Monad, MonadIO, MonadError (Maybe DaideError)
                               , MonadReader DaideHandleInfo, State.MonadState L.ByteString)

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
    contents <- State.get
    return =<< deserialise contents

  askDaideTimed timedelta = DaideAsk $ do
    byteString <- State.get
    ret <- deserialise byteString
    mret <- liftIO . timeout timedelta . evaluate $ ret
    maybe (throwEM TimerPopped) return mret

instance (MonadIO m) => DaideErrorClass (DaideHandleT m) where
  throwEM = throwError . Just

instance (MonadIO m) => DaideErrorClass (DaideTellT m) where
  throwEM = DaideTell . throwEM

instance (MonadIO m) => DaideErrorClass (DaideAskT m) where
  throwEM = DaideAsk . throwEM

noteWith :: (MonadIO m, MonadReader DaideHandleInfo m) => (String -> String -> IO ()) -> String -> m ()
noteWith f msg = do
  -- we have to "force" (because of lazy strings) AND evaluate (because of lazy usage)
  toPrint <- liftIO . evaluate . force $ msg
  name <- asks hostName
  port <- asks hostPort
  time <- liftIO getCurrentTime
  liftIO . f "Main" $  show time ++ " [" ++ name ++ " : " ++ show port ++ "] " ++ toPrint

note :: (MonadIO m, MonadReader DaideHandleInfo m) => String -> m ()
note = noteWith noticeM

runDaideT :: (MonadIO m) => DaideHandleT m () -> DaideHandleInfo -> m ()
runDaideT daide info = do
  contents <- liftIO $ L.hGetContents (socketHandle info)
  _ <- runReaderT (State.runStateT (runErrorT (runDaideHandle daide)
                                    >>= handleError
                                   ) contents
                  ) info
  return ()

shutdownDaide :: (MonadIO m) => DaideHandleT m a
shutdownDaide = throwError Nothing

shutdownDaideAsk :: (MonadIO m) => DaideAskT m a
shutdownDaideAsk = DaideAsk shutdownDaide

shutdownDaideTell :: (MonadIO m) => DaideTellT m a
shutdownDaideTell = DaideTell shutdownDaide

handleError :: (MonadIO m, MonadDaideTell m, MonadReader DaideHandleInfo m) => Either (Maybe DaideError) a -> m ()
handleError = flip either (const $ return ()) . maybe (return ()) $  -- if Nothing it was a clean shutdown
              \err -> do        -- otherwise print and signal the other party
                noteWith errorM $ "An error occured: " ++ (show err)
                tellDaide (EM err)

deserialise :: (MonadIO m) => L.ByteString -> DaideHandleT m DaideMessage
deserialise byteString = do
  e <- liftIO . try . evaluate . runGetLazyState get $ byteString
  (ret, rest) <- either throwError (either (throwEM . WillDieSorry) return) e
  State.put rest
  return ret

serialise :: (MonadReader DaideHandleInfo m) => DaideMessage -> m L.ByteString
serialise message = return (encodeLazy message)

echoHandle :: (MonadIO m) => DaideHandleT m ()
echoHandle = do
  hndle <- asks socketHandle
  liftIO $ L.hGetContents hndle >>= L.hPut hndle

