{-# LANGUAGE TypeSynonymInstances, GeneralizedNewtypeDeriving #-}
module Diplomacy.SkelBot.Comm(CommT, runCommT,
                              popPressMessage,
                              pushPressMessage) where

import Diplomacy.Common.DipMessage

import Control.Monad.Reader
import Control.Monad.Trans
import Control.Concurrent.STM
import Data.Sequence

type PressMessageQueue = TChan PressMessage
                       -- (receiver, dispatcher)
newtype CommT m a = CommT (ReaderT (PressMessageQueue, PressMessageQueue) m a)
                  deriving (Monad, Functor, MonadTrans
                           , MonadReader (PressMessageQueue, PressMessageQueue))

instance (MonadIO m) => MonadIO (CommT m) where
  liftIO = lift . liftIO

runCommT :: (Monad m) => CommT m a -> (PressMessageQueue, PressMessageQueue) -> m a
runCommT (CommT comm) recdis = runReaderT comm recdis

askDispatcher :: (Monad m) => CommT m PressMessageQueue
askDispatcher = fmap fst ask

askReceiver :: (Monad m) => CommT m PressMessageQueue
askReceiver = fmap snd ask

popPressMessage :: (MonadIO m) => CommT m PressMessage
popPressMessage = do
  dispatcher <- askDispatcher
  liftIO (atomically (readTChan dispatcher))

pushPressMessage :: (MonadIO m) => PressMessage -> CommT m ()
pushPressMessage msg = do
  receiver <- askReceiver
  liftIO (atomically (writeTChan receiver msg))
