{-# LANGUAGE MultiParamTypeClasses #-}

module Diplomacy.AI.SkelBot.DipBot where

import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Decision

import Control.Monad.State

-- |results of a turn
data Results = ASD

data DipBot m d h = DipBot { dipBotBrainComm :: BrainCommT d h m ()
                           , dipBotProcessResults :: Results -> h -> h
                           , dipBotInitHistory :: m h }
