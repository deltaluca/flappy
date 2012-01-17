-- |TStream is a concurrently accessible stream usable in parsec that helps make the communication protocol a context sensitive grammar:)
{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances #-}

module Diplomacy.Common.TStream( TStream(..)
                               , newTStream ) where

import Control.Concurrent.STM
import Control.Monad.IO.Class
import Text.Parsec.Prim
  
-- |a "linked list" for concurrently accessible elements
type TVarList a = TVar (TList a)
data TList a = TNil | TCons a (TVarList a)

-- |the linked list plus a "popping" stm action
data TStream a = TStream (TVarList a) (STM a)

-- |creates a new TStream
newTStream :: (MonadIO m) => STM a -> m (TStream a)
newTStream stm = do
  tVarList <- liftIO $ newTVarIO TNil
  return $ TStream tVarList stm

-- |Parsec's Stream instance. Later we may want to change MonadIO to MonadSTM
instance (MonadIO m) => Stream (TStream a) m a where
  uncons (TStream tVar ma) = liftIO . atomically $ do
    tVarList <- readTVar tVar
    case tVarList of
      -- pop an element if it's the end of the list.
      TNil -> do
        a <- ma
        newTVarList <- newTVar TNil
        writeTVar tVar (TCons a newTVarList)
        return (Just (a, TStream newTVarList ma))
      -- if we already have the element return it with the rest of the stream
      TCons a restTVarList -> return (Just (a, TStream restTVarList ma))
