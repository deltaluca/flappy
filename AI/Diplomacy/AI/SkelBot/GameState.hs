module Diplomacy.AI.SkelBot.GameState where

-- | Common date required by every AI bot

import Diplomacy.Common.Data

data GameState = GameState { gameStateMap :: MapState
                           , gameStateRound :: Int
                           , gameStatePhase :: Phase }
               deriving (Show)
    

  
