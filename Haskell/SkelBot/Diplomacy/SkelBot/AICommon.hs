module Diplomacy.AI.StateEncoding where

-- | Common date required by every AI bot

import Diplomacy.Common.Data.MapState

data GameState = GameState
  { currentState :: MapState,  
    gameRound :: Int
  } deriving (Data, Show) 
    

  
