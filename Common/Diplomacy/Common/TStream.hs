-- |TStream is a concurrently accessible stream usable in parsec that helps make the communication protocol a context sensitive grammar:)
{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances #-}

module Diplomacy.Common.TStream(TStream(..)) where

import Diplomacy.Common.MonadSTM

import Control.Concurrent.STM
import Text.Parsec.Prim

-- dirty dirty
type TVarList a = TVar (TList a)
data TList a = TNil | TCons a (TVarList a)
data TStream m a = TStream (TVarList a) (m a)


instance (MonadSTM m) => Stream (TStream m a) m a where
  uncons (TStream tVar ma) = do
    tVarList <- liftSTM (readTVar tVar)
    case tVarList of
      TNil -> do
        a <- ma
        liftSTM $ do
          newTVarList <- newTVar TNil
          writeTVar tVar (TCons a newTVarList)
          return (Just (a, TStream newTVarList ma))
      TCons a restTVarList -> return (Just (a, TStream restTVarList ma))
