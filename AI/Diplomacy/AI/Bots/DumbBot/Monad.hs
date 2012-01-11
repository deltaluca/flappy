{-# LANGUAGE TypeSynonymInstances, FlexibleInstances, MultiParamTypeClasses #-}
module Diplomacy.AI.Bots.DumbBot.Monad where

import Diplomacy.Common.Data
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.CommonCache

import System.Random
import Control.Monad.Random
import Control.Monad.Trans
--import Control.DeepSeq

-- pure brains

type DumbBrain o = RandT StdGen (BrainCacheT (Brain o ()))

-- type DumbBrainMove = DumbBrain OrderMovement
-- type DumbBrainRetreat = DumbBrain OrderRetreat
-- type DumbBrainBuild = DumbBrain OrderBuild

-- impure brains
type DumbBrainCommT o = BrainCommT o ()

type DumbBrainMoveCommT = BrainCommT OrderMovement ()
type DumbBrainRetreatCommT = BrainCommT OrderRetreat ()
type DumbBrainBuildCommT = BrainCommT OrderBuild ()

instance (OrderClass o) => MonadBrainCache (DumbBrain o) where
  askCache = lift askCache
