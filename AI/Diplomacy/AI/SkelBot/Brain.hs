-- |The Brain, GameKnowledge and BrainComm monads and transformers
{-# LANGUAGE 
  MultiParamTypeClasses
, FlexibleInstances
, UndecidableInstances
, OverlappingInstances
, GeneralizedNewtypeDeriving
, FunctionalDependencies #-}

module Diplomacy.AI.SkelBot.Brain ( Brain, BrainT
                                  , BrainCommT
                                  , mapBrainT
                                  , mapBrain
                                  , runBrainT
                                  , runBrain
                                  , liftBrain
                                  , pureBrain
                                  , unliftBrainCommT
                                  , mapBrainCommT
                                  , runBrainCommT
                                  , runGameKnowledgeT
                                  , flushOrders
                                  , mapBrainTHist
                                  , mapBrainCommTHist
                                  , GameKnowledgeT
                                  , MonadGameKnowledge(..)
                                  , MonadBrain(..)) where

import Diplomacy.Common.Data
import Diplomacy.Common.Press
import Diplomacy.Common.TSeq
import Diplomacy.Common.MonadSTM
import Diplomacy.AI.SkelBot.Comm

import Data.Functor
import Control.Applicative
import Control.Monad.Reader
import Control.Monad.State
import Control.Monad.Identity
import Control.Concurrent.STM

newtype GameKnowledgeT h m a = GameKnowledge (StateT h (ReaderT GameInfo m) a)
                             deriving (Applicative, Monad, MonadReader GameInfo, MonadState h)

instance MonadTrans (GameKnowledgeT h) where
  lift = GameKnowledge . lift . lift

runGameKnowledgeT :: (Monad m) => GameKnowledgeT h m a -> GameInfo -> h -> m (a, h)
runGameKnowledgeT (GameKnowledge knowledge) mapDef initHistory =
  runReaderT (runStateT knowledge initHistory) mapDef

class (Monad m) => MonadGameKnowledge h m | m -> h where
  askGameInfo :: m GameInfo
  asksGameInfo :: (GameInfo -> a) -> m a
  getHistory :: m h
  getsHistory :: (h -> a) -> m a
  modifyHistory :: (h -> h) -> m ()
  putHistory :: h -> m ()

  askGameInfo = asksGameInfo id
  getHistory = getsHistory id
  modifyHistory f = putHistory . f =<< getHistory

instance (Monad m) => MonadGameKnowledge h (GameKnowledgeT h m) where
  asksGameInfo = GameKnowledge . asks
  getsHistory = GameKnowledge . gets
  putHistory = GameKnowledge . put

  -- |h = history type(bound by brain), o = order type(bound by SkelBot)
newtype BrainT o h m a = Brain (ReaderT GameState (StateT (Maybe [o]) (GameKnowledgeT h m)) a)
                       deriving (Applicative, Monad, MonadReader GameState, MonadState (Maybe [o]))

type OrderVar o = TVar (Maybe [o])

newtype BrainCommT o h m a = BrainComm (ReaderT (OrderVar o) (CommT InMessage OutMessage (BrainT o h m)) a)
                           deriving (Applicative, Monad)

instance (OrderClass o) => MonadTrans (BrainT o h) where
  lift = Brain . lift . lift . lift

instance OrderClass o => MonadTrans (BrainCommT o h) where
  lift = BrainComm . lift . lift . lift

instance (MonadIO m) => MonadIO (GameKnowledgeT h m) where
  liftIO = GameKnowledge . lift . liftIO

instance (MonadIO m, OrderClass o) => MonadIO (BrainT o h m) where
  liftIO = Brain . lift . liftIO

instance (OrderClass o, MonadSTM m) => MonadSTM (BrainT o h m) where
  liftSTM = lift . liftSTM

instance (MonadIO m, OrderClass o) => MonadIO (BrainCommT o h m) where
  liftIO = BrainComm . lift . lift . lift . liftIO

instance (Monad m) => Functor (GameKnowledgeT h m) where
  fmap = liftM

instance (Monad m, OrderClass o) => Functor (BrainT o h m) where
  fmap = liftM

instance (Monad m, OrderClass o) => Functor (BrainCommT o h m) where
  fmap = liftM

instance (Monad m, OrderClass o) => MonadGameKnowledge h (BrainT o h m) where
  asksGameInfo = liftGameKnowledge . asksGameInfo
  getsHistory = liftGameKnowledge . getsHistory
  putHistory = liftGameKnowledge . putHistory
  
instance (OrderClass o, MonadBrain o m, MonadTrans t, Monad (t m)) =>
         MonadBrain o (t m) where
  asksGameState = lift . asksGameState
  getsOrders = lift . getsOrders
  putOrders = lift . putOrders

instance (MonadGameKnowledge h m, MonadTrans t, Monad (t m)) =>
         MonadGameKnowledge h (t m) where
  asksGameInfo = lift . asksGameInfo
  getsHistory = lift . getsHistory
  putHistory = lift . putHistory

class (Monad m, OrderClass o) => MonadBrain o m | m -> o where
  asksGameState :: (GameState -> a) -> m a
  getsOrders :: ([o] -> a) -> m (Maybe a)
  askGameState :: m GameState
  getOrders :: m (Maybe [o])
  putOrders :: Maybe [o] -> m ()
  appendOrder :: o -> m ()

  askGameState = asksGameState id
  getOrders = getsOrders id
  appendOrder o = putOrders . Just . maybe [o] (o :) =<< getOrders

instance (Monad m, OrderClass o) => MonadBrain o (BrainT o h m) where
  asksGameState = Brain . asks
  getsOrders f = maybe (return Nothing) (return . Just . f) =<< Brain get
  putOrders o = Brain (put o)

-- |lifting, unlifting and mapping functions for easy brain composition
liftGameKnowledge :: (Monad m, OrderClass o) => GameKnowledgeT h m a -> BrainT o h m a
liftGameKnowledge = Brain . lift . lift

runBrainT :: (OrderClass o) => BrainT o h m a -> GameState -> GameKnowledgeT h m (a, Maybe [o])
runBrainT (Brain brain) mapSt = runStateT (runReaderT brain mapSt) Nothing

mapBrainT :: (Monad m, Monad n, OrderClass o) =>
             (m ((a, Maybe [o]), h) -> n ((b, Maybe [o]), h)) ->
             BrainT o h m a -> BrainT o h n b
mapBrainT f mbrain = do
  a <- askGameState
  b <- askGameInfo
  c <- getHistory
  ((ret, orders), c2) <- lift . f $ runGameKnowledgeT (runBrainT mbrain a) b c
  putHistory c2
  putOrders orders
  return ret

mapBrainTHist :: (Monad m, OrderClass o) => (h2 -> h1) ->
                 BrainT o h1 m a -> BrainT o h2 m (a, h1)
mapBrainTHist f brain = do
  a <- askGameState
  b <- askGameInfo
  c <- getHistory
  ((ret, orders), newHist) <- lift $ return =<< runGameKnowledgeT (runBrainT brain a) b (f c)
  putOrders orders
  return (ret, newHist)

mapBrainCommTHist  :: (Monad m, OrderClass o) => (h2 -> h1) ->
                      BrainCommT o h1 m a -> BrainCommT o h2 m (a, h1)
mapBrainCommTHist f = mapBrainCommT (mapBrainTHist f)

type Brain o h = BrainT o h Identity

mapBrain :: (Monad m, OrderClass o) =>
            (((a, Maybe [o]), h) -> m ((b, Maybe [o]), h)) ->
            Brain o h a -> BrainT o h m b
mapBrain f = mapBrainT (f . runIdentity)

unliftBrainCommT :: (Monad m, Monad n, OrderClass o) =>
                    BrainCommT o h1 m a -> BrainCommT o h2 n (BrainT o h1 m a)
unliftBrainCommT (BrainComm br) = do
  ovar <- BrainComm ask
  (inp, outp) <- BrainComm . lift $ askChans
  return (runCommT (runReaderT br ovar) inp outp)

mapBrainCommT :: (Monad m, Monad n, OrderClass o) =>
                 ((BrainT o h1 m a) -> (BrainT o h2 n b)) ->
                 BrainCommT o h1 m a -> BrainCommT o h2 n b
mapBrainCommT f bm = unliftBrainCommT bm >>= liftBrain . f

runBrain :: (Monad m, OrderClass o) => Brain o h a -> BrainT o h m a
runBrain = mapBrain return

liftBrain :: (Monad m, OrderClass o) => BrainT o h m a -> BrainCommT o h m a
liftBrain = BrainComm . lift . lift

pureBrain :: (Monad m, OrderClass o) => Brain o h a -> BrainCommT o h m a
pureBrain = liftBrain . runBrain

instance (MonadSTM m, OrderClass o) => MonadComm InMessage OutMessage (BrainCommT o h m) where
  popMsg = BrainComm . lift $ popMsg
  peekMsg = BrainComm . lift $ peekMsg
  pushMsg = BrainComm . lift . pushMsg
  pushBackMsg = BrainComm . lift . pushBackMsg

instance (Monad m, OrderClass o) => MonadBrain o (BrainCommT o h m) where
  asksGameState = liftBrain . asksGameState
  getsOrders = liftBrain . getsOrders
  putOrders = liftBrain . putOrders

instance (Monad m, OrderClass o) => MonadGameKnowledge h (BrainCommT o h m) where
  asksGameInfo = liftBrain . asksGameInfo
  getsHistory = liftBrain . getsHistory
  putHistory = liftBrain . putHistory

runBrainCommT :: (Monad m, OrderClass o) => BrainCommT o h m a -> OrderVar o ->
                 TSeq InMessage -> TSeq OutMessage -> BrainT o h m a
runBrainCommT (BrainComm m) dVar inq outq = runCommT (runReaderT m dVar) inq outq

flushOrders :: (MonadIO m, OrderClass o) => [o] -> BrainCommT o h m ()
flushOrders orders = do
  tVar <- BrainComm ask
  liftIO . atomically $ do 
    writeTVar tVar (Just orders)
