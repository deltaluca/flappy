module Diplomacy.AI.Bots.DumbBot.Monad where

import Diplomacy.AI.SkelBot.SkelBot
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.DipBot
import Diplomacy.AI.SkelBot.Common
import Diplomacy.AI.SkelBot.CommonCache

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
