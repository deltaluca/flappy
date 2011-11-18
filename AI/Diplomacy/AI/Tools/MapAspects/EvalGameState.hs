
-- | Evaluation function on the game state

module Diplomacy.AI.GameAspects where       

import Diplomacy.AI.StateEncoding.GameState
import Diplomacy.Common.Data.Power


-- | Game aspects 

class GameAspect a where
  getMeasure :: GameState -> Power -> Float
deriving (Show)
  
-- | Number of supply centers controlled by a player
instance GameAspect SupplyCenterControl where
  
  
  -- | Returns number of supply centers owned by power N
  getMeasure ((supplyCenterOwners,_),_) (Power n) =
   map cntOwnedProvinces supplyCenterOwners   
   
   where
     cntOwnerProvinces :: SupplyCenterOwners -> Int
    
  
  
  
instance GameAspect 


-- | 

eval :: GameState -> 



