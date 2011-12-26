{-# LANGUAGE TypeSynonymInstances, FlexibleInstances, FlexibleContexts #-}

-- MonadSTM needed for TStream

module Diplomacy.Common.MonadSTM(MonadSTM(..)) where

import Control.Monad.Reader
import Control.Monad.State
import Control.Concurrent.STM

class (Monad m) => MonadSTM m where
  liftSTM :: STM a -> m a
  getSTM :: m a -> m (STM a)

instance MonadSTM STM where
  liftSTM = id
  getSTM = return

instance (MonadSTM m) => MonadSTM (ReaderT r m) where
  liftSTM = lift . liftSTM
  getSTM = liftM return

instance (MonadSTM m) => MonadSTM (StateT r m) where
  liftSTM = lift . liftSTM
  getSTM = liftM return
