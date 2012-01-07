{-# LANGUAGE TypeSynonymInstances, FlexibleInstances, MultiParamTypeClasses #-}
module Diplomacy.AI.Bots.LearnBot.Monad where

import Diplomacy.Common.Data
import Diplomacy.AI.SkelBot.Brain

import Control.Monad.Random
import Control.Monad.Trans

-- no pure brains blah

-- impure brains
type LearnBrainT o m = RandT StdGen (BrainCommT o [[(Int,Int)]] m)

type LearnBrainMoveT m = LearnBrainT OrderMovement m
type LearnBrainRetreatT m = LearnBrainT OrderRetreat m
type LearnBrainBuildT m = LearnBrainT OrderBuild m

instance (OrderClass o, MonadIO m) => MonadBrain o (LearnBrainT o m) where
  asksGameState = lift . asksGameState
  getsOrders = lift . getsOrders
  putOrders = lift . putOrders

instance (OrderClass o, MonadIO m) => MonadGameKnowledge [[(Int,Int)]] (LearnBrainT o m) where
  asksGameInfo = lift . asksGameInfo
  getsHistory = lift . getsHistory
  putHistory = lift . putHistory
