{-# LANGUAGE MultiParamTypeClasses #-}

module Diplomacy.AI.SkelBot.DipBot where

import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Decision

import Control.Monad.State

  -- |results of a turn
data Results = ASD

class (Decision d) => DipBot d h b where
  botBrain :: (MonadIO m) => b -> BrainCommT d h m ()
  processResults :: b -> Results -> h -> h
  initHistory :: (MonadIO m) => b -> m h
