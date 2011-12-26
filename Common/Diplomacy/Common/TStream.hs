-- |TStream is a concurrently accessible stream usable in parsec that helps make the communication protocol a context sensitive grammar:)
{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances #-}

module Diplomacy.Common.TStream( TStream(..)
                               , newTStream ) where

import Control.Concurrent.STM
import Control.Monad.IO.Class
import Text.Parsec.Prim

-- dirty dirty
type TVarList a = TVar (TList a)
data TList a = TNil | TCons a (TVarList a)
data TStream a = TStream (TVarList a) (STM a)

newTStream :: (MonadIO m) => STM a -> m (TStream a)
newTStream stm = do
  tVarList <- liftIO $ newTVarIO TNil
  return $ TStream tVarList stm

instance (MonadIO m) => Stream (TStream a) m a where
  uncons (TStream tVar ma) = liftIO . atomically $ do
    tVarList <- readTVar tVar
    case tVarList of
      TNil -> do
        a <- ma
        newTVarList <- newTVar TNil
        writeTVar tVar (TCons a newTVarList)
        return (Just (a, TStream newTVarList ma))
      TCons a restTVarList -> return (Just (a, TStream restTVarList ma))
