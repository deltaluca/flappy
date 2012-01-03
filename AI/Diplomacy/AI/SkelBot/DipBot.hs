{-# LANGUAGE MultiParamTypeClasses #-}

module Diplomacy.AI.SkelBot.DipBot where

import Diplomacy.Common.Data
import Diplomacy.AI.SkelBot.Brain

-- |interface to SkelBot
data DipBot m h = DipBot { dipBotBrainMovement :: BrainCommT OrderMovement h m ()
                         , dipBotBrainRetreat :: BrainCommT OrderRetreat h m ()
                         , dipBotBrainBuild :: BrainCommT OrderBuild h m ()
                         , dipBotProcessResults :: [(Order, OrderResult)] -> h -> h
                         , dipBotInitHistory :: m h 
                         , dipBotName :: String
                         , dipBotVersion :: Double }
