module Diplomacy.Common.Data ( Power(..)
                             , SupplyCentreOwnership(..)
                             , SupplyCentreOwnerships
                             , Province(..)
                             , Provinces(..)
                             , ProvinceInter(..)
                             , Coast(..)
                             , UnitType(..)
                             , Phase(..)
                             , MapDefinition(..)
                             , MapState(..)
                             , UnitPositions(..)
                             , UnitPosition(..)
                             , UnitToProv(..)
                             , ProvinceNode(..)
                             , Turn(..)
                             , Adjacency(..)) where

-- | Numbering fixed in ...
data Power 
         = Power Int
         | Neutral
         deriving (Show, Eq)
                      
data SupplyCentreOwnership
         = SupplyCentre Power [Province]
         deriving (Show, Eq)                  
                  
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
                   deriving (Show, Eq)

data Provinces = Provinces SupplyCentreOwnerships [Province]
               deriving (Show, Eq)

-- | Definition of MapState, used by the MessageParser and 
-- | AI internals

type SupplyCentreOwnerships = [SupplyCentreOwnership]

data UnitPositions = UnitPositions Turn [UnitPosition] (Maybe [ProvinceNode])
                   deriving (Show, Eq)

data MapState = MapState { supplyOwners :: SupplyCentreOwnerships
                         , unitPositions :: UnitPositions }
              deriving (Show, Eq)

data Adjacency = Adjacency Province [UnitToProv]
               deriving (Show, Eq)

data Turn = Turn Phase Int
            deriving (Show, Eq)

data UnitPosition = UnitPosition Power UnitType ProvinceNode
                  deriving (Show, Eq)

data ProvinceNode = ProvNode Province | ProvCoastNode Province Coast
                  deriving (Show, Eq)

data UnitToProv = UnitToProv UnitType [ProvinceNode]
                | CoastalFleetToProv Coast [ProvinceNode]
                deriving (Show, Eq)

-- | -------------------------------------------------------------                 
