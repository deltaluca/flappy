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

data InMessage = InMessage { inMessageFrom :: Power
                           , inMessageTo :: [Power]
                           , inMessageMessage :: PressMessage }
               deriving (Show)

data OutMessage = OutMessage { outMessageTo :: [Power]
                             , outMessageMessage :: PressMessage }

type InMessageQueue = TSeq InMessage
type OutMessageQueue = TSeq OutMessage

                       -- (receiver, dispatcher)
newtype CommT m a = CommT (ReaderT (InMessageQueue, OutMessageQueue) m a)
                  deriving (Monad, MonadTrans
                           , MonadReader (InMessageQueue, OutMessageQueue))

instance (MonadIO m) => MonadIO (CommT m) where
  liftIO = lift . liftIO

class MonadComm m where
  popInMessage :: m InMessage
  pushOutMessage :: OutMessage -> m ()

runCommT :: (Monad m) => CommT m a -> InMessageQueue -> OutMessageQueue -> m a
runCommT (CommT comm) rec dis = runReaderT comm (rec, dis)
askDispatcher :: (Monad m) => CommT m InMessageQueue
askDispatcher = liftM fst ask

askReceiver :: (Monad m) => CommT m OutMessageQueue
askReceiver = liftM snd ask

instance MonadIO m => MonadComm (CommT m) where
  popInMessage = do
    dispatcher <- askDispatcher
    liftIO (atomically (readTSeq dispatcher))
  pushOutMessage msg = do
    receiver <- askReceiver
    liftIO (atomically (writeTSeq receiver msg))
