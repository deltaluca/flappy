-- | Entities in the game of diplomacy 
module DiplomacyData where

data Power 
         = Power Int -- ^ 
         | Neutral   -- ^
         deriving (Show)
                      
data Province 
         = Inland Int -- ^
         | Sea Int    -- ^
         | Coastal Int -- ^
         | BiCoastal Int -- ^
         deriving (Show, Eq)

data Coast 
         = Coast Int -- ^
         deriving (Show, Eq)


data UnitType 
         = Army -- ^
         | Fleet -- ^
         deriving (Show, Eq)

data Phase 
         = Spring -- ^
         | Summer -- ^
         | Fall -- ^ 
         | Autumn -- ^
         | Winter -- ^
         deriving (Show, Eq)


