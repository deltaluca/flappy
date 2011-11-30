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
                             , Adjacency(..)
                             , Order(..)
                             , OrderRetreat(..)
                             , OrderBuild(..)
                             , OrderMovement(..)
                             ) where

import Test.QuickCheck

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

--for mapdefinition only, [Province] is list of provinces WITHOUT supply centres in them
data Provinces = Provinces SupplyCentreOwnerships [Province]
               deriving (Show, Eq)

-- | Definition of MapState, used by the MessageParser and 
-- | AI internals

type SupplyCentreOwnerships = [SupplyCentreOwnership]

data UnitPositions = UnitPositions Turn [UnitPosition]
                   | UnitPositionsRet Turn [(UnitPosition, [ProvinceNode])]
                   deriving (Show, Eq)

data MapState = MapState { supplyOwnerships :: SupplyCentreOwnerships
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

data Order = OrderMovement OrderMovement
           | OrderRetreat OrderRetreat
           | OrderBuild OrderBuild
           deriving (Eq, Show)

data OrderMovement = Hold UnitPosition
                   | Move UnitPosition ProvinceNode
                   | SupportHold UnitPosition UnitPosition
                   | SupportMove UnitPosition UnitPosition Province
                   | Convoy UnitPosition UnitPosition ProvinceNode
                   | MoveConvoy UnitPosition ProvinceNode [Province]
                   deriving (Eq, Show)

data OrderRetreat = Retreat UnitPosition ProvinceNode
                  | Disband UnitPosition
                  deriving (Eq, Show)

data OrderBuild = Build UnitPosition
                | Remove UnitPosition
                | Waive Power
                deriving (Eq, Show)



-- | -------------------------------------------------------------                 

instance Arbitrary Power where
  arbitrary = frequency [ (1, return Neutral)
                        , (9, return . Power =<< arbitrary)
                        ]


instance Arbitrary MapDefinition where
  arbitrary = do
    p1 <- listOf1 arbitrary
    p2 <- arbitrary
    a <- listOf1 arbitrary
    return $ MapDefinition p1 p2 a

instance Arbitrary Provinces where
  arbitrary = do
    s <- listOf1 arbitrary
    p <- listOf1 arbitrary
    return $ Provinces s p

instance Arbitrary SupplyCentreOwnership where
  arbitrary = do
    p <- arbitrary
    ps <- listOf1 arbitrary
    return $ SupplyCentre p ps

instance Arbitrary Province where
  arbitrary = do
    b <- arbitrary
    p <- arbitrary
    return $ Province b p

instance Arbitrary ProvinceInter where
  arbitrary = oneof [ return . Inland =<< arbitrary
                    , return . Sea =<< arbitrary
                    , return . Coastal =<< arbitrary
                    , return . BiCoastal =<< arbitrary
                    ]

instance Arbitrary Adjacency where
  arbitrary = do
    p <- arbitrary
    up <- listOf1 arbitrary
    return $ Adjacency p up

instance Arbitrary UnitToProv where
  arbitrary = frequency [ (2, do
                              u <- arbitrary
                              pn <- listOf1 arbitrary
                              return $ UnitToProv u pn)
                        , (1, do
                              c <- arbitrary
                              pn <- listOf1 arbitrary
                              return $ CoastalFleetToProv c pn)
                        ]

instance Arbitrary ProvinceNode where
  arbitrary = oneof [ return . ProvNode =<< arbitrary
                    , do
                      p <- arbitrary
                      c <- arbitrary
                      return $ ProvCoastNode p c
                    ]

instance Arbitrary UnitType where
  arbitrary = oneof [ return Army
                    , return Fleet
                    ]

instance Arbitrary Coast where
  arbitrary = return . Coast =<< arbitrary
