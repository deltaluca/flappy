{-# LANGUAGE TypeSynonymInstances #-}
module Diplomacy.SkelBot.Comm(CommT, runCommT,
                              popDipMessage,
                              pushDipMessage) where

-- |BrainComm is an impure brain the communicates with the message queues

import Diplomacy.Common.DipMessage

import Control.Monad.Reader
import Control.Monad.Trans
import Control.Concurrent.STM
import Data.Sequence

type DipMessageQueue = TChan PressMessage
                       -- (receiver, dispatcher)
type CommT m = ReaderT (DipMessageQueue, DipMessageQueue) m

runCommT :: (Monad m) => CommT m a -> (DipMessageQueue, DipMessageQueue) -> m a
runCommT comm recdis = runReaderT comm recdis

askDispatcher :: (Monad m) => CommT m DipMessageQueue
askDispatcher = fmap fst ask

askReceiver :: (Monad m) => CommT m DipMessageQueue
askReceiver = fmap snd ask

popDipMessage :: CommT IO DipMessage
popDipMessage = do
  dispatcher <- askDispatcher
  (lift . lift) (atomically (readTChan dispatcher))

pushDipMessage :: DipMessage -> CommT IO ()
pushDipMessage msg = do
  receiver <- askReceiver
  (lift . lift) (atomically (writeTChan receiver msg))
