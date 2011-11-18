{-# LANGUAGE TypeSynonymInstances, GeneralizedNewtypeDeriving #-}
module Diplomacy.AI.SkelBot.Comm( CommT, runCommT
                                , popPressMessage
                                , pushPressMessage
                                , DipMessageQueue) where

import Diplomacy.Common.DipMessage

import Control.Monad.Reader
import Control.Monad.Trans
import Control.Concurrent.STM

type DipMessageQueue = TChan DipMessage
                       -- (receiver, dispatcher)
newtype CommT m a = CommT (ReaderT (DipMessageQueue, DipMessageQueue) m a)
                  deriving (Monad, Functor, MonadTrans
                           , MonadReader (DipMessageQueue, DipMessageQueue))

instance (MonadIO m) => MonadIO (CommT m) where
  liftIO = lift . liftIO

runCommT :: (Monad m) => CommT m a -> (DipMessageQueue, DipMessageQueue) -> m a
runCommT (CommT comm) recdis = runReaderT comm recdis

askDispatcher :: (Monad m) => CommT m DipMessageQueue
askDispatcher = fmap fst ask

askReceiver :: (Monad m) => CommT m DipMessageQueue
askReceiver = fmap snd ask

popDipMessage :: (MonadIO m) => CommT m DipMessage
popDipMessage = do
  dispatcher <- askDispatcher
  liftIO (atomically (readTChan dispatcher))

pushDipMessage :: (MonadIO m) => DipMessage -> CommT m ()
pushDipMessage msg = do
  receiver <- askReceiver
  liftIO (atomically (writeTChan receiver msg))
