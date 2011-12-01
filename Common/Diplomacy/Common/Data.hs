{- |

  Defines concepts of the game of diplomacy (see game rules),
  which all components will use. To be distinguished from
  messaging syntax (DAIDE etc..)

-} 

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

import Test.QuickCheck -- Unit testing
import qualified Data.Map as Map  -- Use for all dictionary types

-- | Misc. game entities

data Power 
         = Power { powerId :: Int }
         | Neutral
         deriving (Show, Eq)
                                
data Province 
         = Province { provinceIsSupply :: Bool, 
                      provinceType :: ProvinceType,
                      provinceId :: Int }
         deriving (Show, Eq)
            
data ProvinceType
         = Inland | Sea | Coastal | BiCoastal
         deriving (Show, Eq)
                  
data Coast 
         = Coast { coastId :: Int }
         deriving (Show, Eq)

data UnitType 
         = Army
         | Fleet
         deriving (Show, Eq)

data Turn = Turn { turnPhase :: Phase
                 , turnYear :: Int }
            deriving (Show, Eq)

data Phase 
         = Spring | Summer | Fall | Autumn | Winter
         deriving (Show, Eq)

-- | Map topology definitions

data MapDefinition = MapDefinition { mapDefPowers :: [Power]
                                   , mapDefProvinces :: [Province]
                                   , mapDefAdjacencies :: [Adjacency]
                                   , mapDefSupplyInit :: [SupplyCOwnership] }
                   deriving (Show, Eq)

type Adjacency = Map.Map Province [UnitToProv]


-- | Dynamic game state definitions

data GameState = GameState { gameStateMap :: MapState
                           , gameStateRound :: Int
                           , gameStatePhase :: Phase }
               deriving (Show)

data MapState = MapState { supplyOwnerships :: [SupplyCOwnership]
                         , unitPositions :: UnitPositions }
              deriving (Show, Eq)

type SupplyCOwnership = Map.Map Power [Province]


data UnitPositions = UnitPositions Turn [UnitPosition]
                   | UnitPositionsRet Turn [(UnitPosition, [ProvinceNode])]
                   deriving (Show, Eq)

data UnitPosition = UnitPosition { unitPositionP :: Power
                                 , unitPositionT :: UnitType
                                 , unitPositionLoc :: ProvinceNode }
                  deriving (Show, Eq)

data ProvinceNode = ProvNode Province 
                  | ProvCoastNode Province Coast
                  deriving (Show, Eq)

data UnitToProv = UnitToProv UnitType [ProvinceNode]
                | CoastalFleetToProv Coast [ProvinceNode]
                deriving (Show, Eq)

-- | Definitions for Orders

data Order = OrderMovement { orderMove :: OrderMovement }
           | OrderRetreat { orderRetreat :: OrderRetreat }
           | OrderBuild { orderBuild :: OrderBuild } 
           deriving (Eq, Show)

-- | Spring term
data OrderMovement = Hold UnitPosition
                   | Move UnitPosition ProvinceNode
                   | SupportHold UnitPosition UnitPosition
                   | SupportMove UnitPosition UnitPosition Province
                   | Convoy UnitPosition UnitPosition ProvinceNode
                   | MoveConvoy UnitPosition ProvinceNode [Province]
                   deriving (Eq, Show)

-- | Summer term
data OrderRetreat = Retreat UnitPosition ProvinceNode
                  | Disband UnitPosition
                  deriving (Eq, Show)

-- | Winter term
data OrderBuild = Build UnitPosition
                | Remove UnitPosition
                | Waive Power
                deriving (Eq, Show)De



-- | -------------UNIT TEST DEFS ------------------------------------------                

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
