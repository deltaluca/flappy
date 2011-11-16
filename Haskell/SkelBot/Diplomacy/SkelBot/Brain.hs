{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances, GeneralizedNewtypeDeriving #-}

module Diplomacy.SkelBot.Brain where

import Diplomacy.SkelBot.Decision
import Diplomacy.SkelBot.MapState
import Diplomacy.SkelBot.MapDef

import Control.Monad.Reader
import Control.Monad.State
import Control.Monad.Identity

newtype (Monad m) => GameKnowledgeT h m a = GameKnowledge (StateT h (ReaderT MapDef m) a)
                                          deriving (Monad, MonadReader MapDef, MonadState h)
                                                   
instance MonadTrans (GameKnowledgeT h) where
  lift = GameKnowledge . lift . lift

class Monad m => GameKnowledgeMonad h m where
  askMapDef :: m MapDef
  getHistory :: m h
  asksMapDef :: (MapDef -> a) -> m a
  getsHistory :: (h -> a) -> m a

instance Monad m => GameKnowledgeMonad h (GameKnowledgeT h m) where
  askMapDef = ask
  getHistory = get
  asksMapDef = asks
  getsHistory = gets

  -- |h = history type, d = decision type
newtype (Decision d) => BrainT d h m a = Brain {brainT :: ReaderT MapState (StateT d (GameKnowledgeT h m)) a}
                                     deriving (Monad)

runBrainT :: (Decision d) => MapState -> d -> BrainT d h m a -> GameKnowledgeT h m (a, d)
runBrainT mapState initDecision brain = runStateT (runReaderT (brainT brain) mapState) initDecision

type Brain d h = BrainT d h Identity

type BrainImpure d h = BrainT d h IO



-------


-- type HoldBrain = Brain DipMessage ()

-- asd :: HoldBrain a
-- asd = do
--   history <- askHistory
