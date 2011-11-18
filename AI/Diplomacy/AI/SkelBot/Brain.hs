{-# LANGUAGE 
  MultiParamTypeClasses
, FlexibleInstances
, GeneralizedNewtypeDeriving
, FunctionalDependencies #-}

module Diplomacy.AI.SkelBot.Brain ( BrainT, Brain, GameKnowledgeT
                               , GameKnowledgeMonad(..)
                               , BrainMonad(..)) where

import Diplomacy.AI.SkelBot.Decision
import Diplomacy.Common.Data

import Control.Monad.Reader
import Control.Monad.State
import Control.Monad.Identity
import Data.Functor

newtype GameKnowledgeT h m a = GameKnowledge (StateT h (ReaderT MapDef m) a)
                             deriving (Monad, MonadReader MapDef, MonadState h)

instance MonadTrans (GameKnowledgeT h) where
  lift = GameKnowledge . lift . lift

runGameKnowledgeT :: (Monad m) => GameKnowledgeT h m a -> MapDef -> h -> m (a, h)
runGameKnowledgeT (GameKnowledge knowledge) mapDef initHistory =
  runReaderT (runStateT knowledge initHistory) mapDef

class (Monad m) => GameKnowledgeMonad h m | m -> h where
  askMapDef :: m MapDef
  asksMapDef :: (MapDef -> a) -> m a
  getHistory :: m h
  getsHistory :: (h -> a) -> m a
  putHistory :: h -> m ()

instance (Monad m) => GameKnowledgeMonad h (GameKnowledgeT h m) where
  askMapDef = GameKnowledge ask
  getHistory = GameKnowledge get
  asksMapDef = GameKnowledge . asks
  getsHistory = GameKnowledge . gets
  putHistory = GameKnowledge . put

  -- |h = history type, d = decision type
newtype BrainT d h m a = Brain (ReaderT MapState (StateT d (GameKnowledgeT h m)) a)
                       deriving (Monad, MonadReader MapState, MonadState d)

instance Decision d => MonadTrans (BrainT d h) where
  lift = Brain . lift . lift . lift

instance (Monad m, Decision d) => GameKnowledgeMonad h (BrainT d h m) where
  askMapDef = liftGameKnowledge askMapDef
  getHistory = liftGameKnowledge getHistory
  asksMapDef = liftGameKnowledge . asksMapDef
  getsHistory = liftGameKnowledge . getsHistory
  putHistory = liftGameKnowledge . putHistory
  
class (Monad m, Decision d) => BrainMonad d m | m -> d where
  askMapState :: m MapState
  asksMapState :: (MapState -> a) -> m a
  getDecision :: m d
  getsDecision :: (d -> a) -> m a
  putDecision :: d -> m ()

instance (Monad m, Decision d) => BrainMonad d (BrainT d h m) where
  askMapState = Brain ask
  asksMapState = Brain . asks
  getDecision = Brain get
  getsDecision = Brain . gets
  putDecision = Brain . put

liftGameKnowledge :: (Monad m, Decision d) => GameKnowledgeT h m a -> BrainT d h m a
liftGameKnowledge = Brain . lift . lift

runBrainT :: (Decision d) => BrainT d h m a -> MapState -> d -> GameKnowledgeT h m (a, d)
runBrainT (Brain brain) mapState initDecision = runStateT (runReaderT brain mapState) initDecision

mapBrainT :: (Monad m, Monad n, Decision d) =>
             (m ((a, d), h) -> n ((b, d), h)) -> BrainT d h m a -> BrainT d h n b
mapBrainT f mbrain = do
  let fmapm f ma = ma >>= return . f
  mapDef <- askMapDef
  mapState <- askMapState
  decision <- getDecision
  history <- getHistory
  ((a, d), h) <- lift (f (runGameKnowledgeT (runBrainT mbrain mapState decision) mapDef history))
  putDecision d
  putHistory h
  return a

type Brain d h = BrainT d h Identity

mapBrain :: (Monad m, Decision d) => (((a, d), h) -> m ((b, d), h)) -> BrainT d h Identity a -> BrainT d h m b
mapBrain f = mapBrainT (f . runIdentity)
