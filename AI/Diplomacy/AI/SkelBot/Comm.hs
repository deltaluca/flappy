{-# LANGUAGE TypeSynonymInstances, GeneralizedNewtypeDeriving #-}
module Diplomacy.AI.SkelBot.Comm( CommT, runCommT
                                , popInMessage
                                , pushOutMessage
                                , InMessage(..)
                                , OutMessage(..)
                                , InMessageQueue
                                , OutMessageQueue
                                , PressMessageQueue) where

import Diplomacy.Common.DipMessage
import Diplomacy.Common.Data
import Control.Monad.Reader
import Control.Monad.Trans
import Control.Concurrent.STM

data InMessage = InMessage { inMessageFrom :: Power
                           , inMessageTo :: [Power]
                           , inMessageMessage :: PressMessage }
               deriving (Show)

data OutMessage = OutMessage { outMessageTo :: [Power]
                             , outMessageMessage :: PressMessage }

type InMessageQueue = TChan InMessage
type OutMessageQueue = TChan OutMessage

                       -- (receiver, dispatcher)
newtype CommT m a = CommT (ReaderT (InMessageQueue, OutMessageQueue) m a)
                  deriving (Monad, MonadTrans
                           , MonadReader (PressMessageQueue, PressMessageQueue))

instance (MonadIO m) => MonadIO (CommT m) where
  liftIO = lift . liftIO

runCommT :: (Monad m) => CommT m a -> (PressMessageQueue, PressMessageQueue) -> m a
runCommT (CommT comm) recdis = runReaderT comm recdis

askDispatcher :: (Monad m) => CommT m InMessageQueue
askDispatcher = liftM fst ask

askReceiver :: (Monad m) => CommT m OutMessageQueue
askReceiver = liftM snd ask

popInMessage :: (MonadIO m) => CommT m InMessage
popInMessage = do
  dispatcher <- askDispatcher
  liftIO (atomically (readTChan dispatcher))

pushOutMessage :: (MonadIO m) => OutMessage -> CommT m ()
pushOutMessage msg = do
  receiver <- askReceiver
  liftIO (atomically (writeTChan receiver msg))
