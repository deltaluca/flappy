{-# LANGUAGE MultiParamTypeClasses #-}

module Diplomacy.AI.SkelBot.DipBot where

import Diplomacy.Common.Data
import Diplomacy.AI.SkelBot.Brain

import Control.Monad.State

-- |results of a turn
type Results = [(Order, OrderResult)]

data DipBot m h = DipBot { dipBotBrainMovement :: BrainCommT OrderMovement h m ()
                         , dipBotBrainRetreat :: Brain OrderRetreat h ()
                         , dipBotBrainBuild :: Brain OrderBuild h ()
                         , dipBotProcessResults :: Results -> h -> h
                         , dipBotInitHistory :: m h 
                         , dipBotName :: String
                         , dipBotVersion :: Double }
