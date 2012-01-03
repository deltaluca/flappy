{-# LANGUAGE TypeSynonymInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleInstances, FunctionalDependencies #-}
module Diplomacy.AI.SkelBot.Comm( CommT, runCommT
                                , MonadComm(..)
                                ) where

import Diplomacy.Common.TSeq
import Diplomacy.Common.MonadSTM

import Control.Monad.Reader
import Control.Concurrent.STM

                       -- (receiver, dispatcher)
newtype CommT i o m a = CommT (ReaderT (TSeq i, TSeq o) m a)
                  deriving (Functor, Monad, MonadIO, MonadTrans
                           , MonadReader (TSeq i, TSeq o))

instance (MonadSTM m) => MonadSTM (CommT i o m) where
  liftSTM = lift . liftSTM
  getSTM = liftM return

class MonadComm i o m | m -> i, m -> o where
  popMsg :: m (STM i)
  peekMsg :: m (STM i)
  pushMsg :: o -> m (STM ())
  pushBackMsg :: i -> m (STM ())

runCommT :: (Monad m) => CommT i o m a -> TSeq i -> TSeq o -> m a
runCommT (CommT comm) rec dis = runReaderT comm (rec, dis)

askDispatcher :: (Monad m) => CommT i o m (TSeq o)
askDispatcher = liftM snd ask

askReceiver :: (Monad m) => CommT i o m (TSeq i)
askReceiver = liftM fst ask

instance Monad m => MonadComm i o (CommT i o m) where
  popMsg = do
    receiver <- askReceiver
    return (readTSeq receiver)
  peekMsg = do
    receiver <- askReceiver
    return (peekTSeq receiver)
  pushMsg msg = do
    dispatcher <- askDispatcher
    return (writeTSeq dispatcher msg)
  pushBackMsg msg = do
    receiver <- askReceiver
    return (requeueTSeq receiver msg)