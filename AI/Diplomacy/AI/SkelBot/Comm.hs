{-# LANGUAGE TypeSynonymInstances, GeneralizedNewtypeDeriving #-}
module Diplomacy.AI.SkelBot.Comm( CommT, runCommT
                                , MonadComm
                                , popInMessage
                                , pushOutMessage
                                , InMessage(..)
                                , OutMessage(..)
                                , InMessageQueue
                                , OutMessageQueue) where

import Diplomacy.Common.DipMessage
import Diplomacy.Common.Data
import Diplomacy.Common.TSeq

import Control.Monad.Reader
import Control.Monad.Trans
import Control.Concurrent.STM

                       -- (receiver, dispatcher)
newtype CommT i o m a = CommT (ReaderT (TSeq i, TSeq o) m a)
                  deriving (Monad, MonadTrans
                           , MonadReader (TSeq i, TSeq o))

instance (MonadIO m) => MonadIO (CommT i o m) where
  liftIO = lift . liftIO

class MonadComm i o m where
  popMsg :: m i
  pushMsg :: o -> m ()

runCommT :: (Monad m) => CommT i o m a -> TSeq i -> TSeq o -> m a
runCommT (CommT comm) rec dis = runReaderT comm (rec, dis)

askDispatcher :: (Monad m) => CommT i o m (TSeq i)
askDispatcher = liftM fst ask

askReceiver :: (Monad m) => CommT i o m (TSeq o)
askReceiver = liftM snd ask

instance MonadIO m => MonadComm (CommT m i o) where
  popMsg = do
    dispatcher <- askDispatcher
    liftIO (atomically (readTSeq dispatcher))
  pushMsg msg = do
    receiver <- askReceiver
    liftIO (atomically (writeTSeq receiver msg))
