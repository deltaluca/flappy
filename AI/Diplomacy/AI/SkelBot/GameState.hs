module Diplomacy.AI.SkelBot.GameState where

-- | Common date required by every AI bot

import Diplomacy.Common.Data

data GameState = GameState { currentState :: MapState,  
                             gameRound :: Int }
               deriving (Show)
    

  
