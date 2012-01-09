{-# LANGUAGE MultiParamTypeClasses #-}

module Diplomacy.AI.SkelBot.DipBot where

import Diplomacy.Common.Data
import Diplomacy.AI.SkelBot.Brain

-- |interface to SkelBot
data DipBot m h = DipBot
                    -- |brain used to make moves (Spring, Fall)
                  { dipBotBrainMovement :: BrainCommT OrderMovement h m ()
                    -- |brain used to make moves (Summer, Autumn)
                  , dipBotBrainRetreat :: BrainCommT OrderRetreat h m ()
                    -- |brain used to build/remove (Winter)
                  , dipBotBrainBuild :: BrainCommT OrderBuild h m ()
                    -- |modify history based on results
                    -- this should really be a monadgameknowledge + prev. gamestate
                  , dipBotProcessResults :: [(Order, OrderResult)] -> h -> h
                    -- |init history based on gameinfo and initial state
                  , dipBotInitHistory :: GameInfo -> GameState -> m h 
                    -- |bot's name
                  , dipBotName :: String
                    -- |bot's version
                  , dipBotVersion :: Double }
