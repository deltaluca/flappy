
module Diplomacy.Common.Data where

-- | Numbering fixed in ...
data Power 
         = Power Int
         | Neutral
         deriving (Show)
                      
data SupplyCentreOwnership
         = SupplyCentre Power [Province]
         deriving (Show)                  
                  
data Province 
         = Province Bool ProvinceInter
         deriving (Show, Eq)

data ProvinceInter
         = Inland Int
         | Sea Int
         | Coastal Int
         | BiCoastal Int
         deriving (Show, Eq)

data Coast 
         = Coast Int
         deriving (Show, Eq)


data UnitType 
         = Army
         | Fleet
         deriving (Show, Eq)

data Phase 
         = Spring
         | Summer
         | Fall 
         | Autumn
         | Winter
         deriving (Show, Eq)

-- | Static definition of map topology

data MapDefinition = MapDefinition { mapDefPowers :: [Power]
                                   , mapDefProvinces :: Provinces
                                   
                                   , mapDefAdjacencies :: [Adjacency] }

-- | Definition of MapState, used by the MessageParser and 
-- | AI internals

type SupplyCenterOwners = [SupplyCenterOwner]

data UnitPositions = Turn [UnitPosition] (Maybe [ProvinceNote])

data MapState =
  
  MapState { currentSupplyOwners :: SupplyCenterOwners
           , currentUnitPositions :: UnitPositions }

data Adjacency = Adjacency Province [UnitToProv]
               
-- | -------------------------------------------------------------                 
                 
               deriving (Show)
