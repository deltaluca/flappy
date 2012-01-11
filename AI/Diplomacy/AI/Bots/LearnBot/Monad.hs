{-# LANGUAGE TypeSynonymInstances, FlexibleInstances, MultiParamTypeClasses #-}
module Diplomacy.AI.Bots.LearnBot.Monad where

import Diplomacy.Common.Data
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.CommonCache

import Control.Monad.Random
import Control.Monad.Reader
import Control.Monad.Trans

import Data.Map as Map

-- no pure brains blah

data LearnHistory = LearnHistory { getPureDB :: PureDB 
                                 , getHist :: [(Double, [(Int, Int)])] }

                                      
type PureDB =  Map.Map (Int,Int) (Int,Int,Double,Int)

-- impure brains
type LearnBrainT o m = RandT StdGen (BrainCacheT (BrainCommT o LearnHistory m))

type LearnBrainMoveT m = LearnBrainT OrderMovement m
type LearnBrainRetreatT m = LearnBrainT OrderRetreat m
type LearnBrainBuildT m = LearnBrainT OrderBuild m

instance (OrderClass o, MonadIO m) => MonadBrainCache (LearnBrainT o m) where
  askCache = lift askCache

instance (OrderClass o, MonadIO m) => MonadBrain o (LearnBrainT o m) where
  asksGameState = lift . lift . asksGameState
  getsOrders = lift . lift . getsOrders
  putOrders = lift . lift . putOrders

instance (OrderClass o, MonadIO m) => MonadGameKnowledge LearnHistory (LearnBrainT o m) where
  asksGameInfo = lift . lift . asksGameInfo
  getsHistory = lift . lift . getsHistory
  putHistory = lift . lift . putHistory
