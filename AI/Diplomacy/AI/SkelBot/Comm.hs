{-# LANGUAGE TypeSynonymInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleInstances, FunctionalDependencies #-}
module Diplomacy.AI.SkelBot.Comm( CommT, runCommT
                                , MonadComm(..)
                                ) where

import Diplomacy.Common.DipMessage
import Diplomacy.Common.Data
import Diplomacy.Common.TSeq

import Control.Monad.Reader
import Control.Monad.Trans
import Control.Concurrent.STM

                       -- (receiver, dispatcher)
newtype CommT i o m a = CommT (ReaderT (TSeq i, TSeq o) m a)
                  deriving (Functor, Monad, MonadTrans
                           , MonadReader (TSeq i, TSeq o))

instance (MonadIO m) => MonadIO (CommT i o m) where
  liftIO = lift . liftIO

class MonadComm i o m | m -> i, m -> o where
  popMsg :: m i
  peekMsg :: m i
  pushMsg :: o -> m ()
  pushBackMsg :: i -> m ()

runCommT :: (Monad m) => CommT i o m a -> TSeq i -> TSeq o -> m a
runCommT (CommT comm) rec dis = runReaderT comm (rec, dis)

askDispatcher :: (Monad m) => CommT i o m (TSeq o)
askDispatcher = liftM snd ask

askReceiver :: (Monad m) => CommT i o m (TSeq i)
askReceiver = liftM fst ask

instance MonadIO m => MonadComm i o (CommT i o m) where
  popMsg = do
    receiver <- askReceiver
    liftIO (atomically (readTSeq receiver))
  peekMsg = do
    receiver <- askReceiver
    liftIO (atomically (peekTSeq receiver))
  pushMsg msg = do
    dispatcher <- askDispatcher
    liftIO (atomically (writeTSeq dispatcher msg))
  pushBackMsg msg = do
    receiver <- askReceiver
    liftIO (atomically (requeueTSeq receiver msg))    