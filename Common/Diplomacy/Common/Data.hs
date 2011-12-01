{- |

  Defines concepts of the game of diplomacy (see game rules),
  which all components will use. To be distinguished from
  messaging syntax (DAIDE etc..)

-} 

module Diplomacy.Common.Data ( Power(..)
                             , SupplyCOwnerships(..)
                             , Province(..)
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
                             , Adjacencies(..)
                             , Order(..)
                             , OrderRetreat(..)
                             , OrderBuild(..)
                             , OrderMovement(..)
                             , GameState(..)
                             , ProvinceType(..)
                             ) where

import Test.QuickCheck -- Unit testing
import qualified Data.Map as Map  -- Use for all dictionary types

-- | Misc. game entities

data Power 
         = Power { powerId :: Int }
         | Neutral
         deriving (Show, Eq)
                                
instance Ord Power where
  Neutral < _ = True
  _ < Neutral = False
  (Power p1) < (Power p2) = p1 < p2

data Province 
         = Province { provinceIsSupply :: Bool, 
                      provinceType :: ProvinceType,
                      provinceId :: Int }
         deriving (Show, Eq)

instance Ord Province where
  p1 > p2 = provinceId p1 > provinceId p2

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
                                   , mapDefAdjacencies :: Adjacencies
                                   , mapDefSupplyInit :: SupplyCOwnerships }
                   deriving (Show, Eq)

newtype Adjacencies = Adjacencies (Map.Map Province [UnitToProv])
                    deriving (Show, Eq)

-- | Dynamic game state definitions

data GameState = GameState { gameStateMap :: MapState
                           , gameStateRound :: Int
                           , gameStatePhase :: Phase }
               deriving (Show)

data MapState = MapState { supplyOwnerships :: SupplyCOwnerships
                         , unitPositions :: UnitPositions }
              deriving (Show, Eq)

newtype SupplyCOwnerships = SupplyCOwnerships (Map.Map Power [Province])
                          deriving (Show, Eq)


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
                deriving (Eq, Show)



-- | -------------UNIT TEST DEFS ------------------------------------------                

instance Arbitrary Power where
  arbitrary = frequency [ (1, return Neutral)
                        , (9, return . Power =<< arbitrary)
                        ]


instance Arbitrary MapDefinition where
  arbitrary = do
    p1 <- listOf1 arbitrary
    p2 <- listOf1 arbitrary
    a <- arbitrary
    s <- arbitrary
    return $ MapDefinition p1 p2 a s

instance Arbitrary SupplyCOwnerships where
  arbitrary = do
    scos <- listOf1 $ do
           p <- arbitrary
           ps <- listOf1 arbitrary
           return (p, ps)
    return . SupplyCOwnerships . Map.fromList $ scos

instance Arbitrary Province where
  arbitrary = do
    b <- arbitrary
    t <- oneof [ return Inland
               , return Sea
               , return Coastal
               , return BiCoastal ]
    i <- arbitrary
    return $ Province b t i

instance Arbitrary Adjacencies where
  arbitrary = do
    adj <- listOf1 $ do
      p <- arbitrary
      up <- listOf1 arbitrary
      return (p, up)
    return . Adjacencies . Map.fromList $ adj

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
