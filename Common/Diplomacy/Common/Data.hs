{- |

  Defines concepts of the game of diplomacy (see game rules),
  which all components will use. To be distinguished from
  messaging syntax (DAIDE etc..)

-} 

module Diplomacy.Common.Data ( Power(..)
                             , SupplyCOwnerships
                             , Province(..)
                             , Coast(..)
                             , UnitType(..)
                             , Phase(..)
                             , MapDefinition(..)
                             , MapState(..)
                             , UnitPositions(..)
                             , UnitPosition(..)
                             , ProvinceNode(..)
                             , Turn(..)
                             , Order(..)
                             , OrderNote(..)
                             , OrderResult(..)
                             , ResultNormal(..)
                             , ResultRetreat(..)
                             , OrderRetreat(..)
                             , OrderBuild(..)
                             , OrderMovement(..)
                             , GameInfo(..)
                             , GameState(..)
                             , ProvinceType(..)
                             , OrderClass(..)
                             ) where

import Control.Monad
import Test.QuickCheck -- Unit testing

import qualified Data.Map as Map  -- Use for all dictionary types

-- | Misc. game entities

data Power 
         = Power { powerId :: Int }
         | Neutral
         deriving (Show)
                                
instance Ord Power where
  _ <= Neutral = False
  Neutral <= _ = True
  (Power p1) <= (Power p2) = p1 <= p2

instance Eq Power where
  Neutral == Neutral = True
  (Power p1) == (Power p2) = p1 == p2
  _ == _ = False

data Province 
         = Province { provinceIsSupply :: Bool, 
                      provinceType :: ProvinceType,
                      provinceId :: Int }
         deriving (Show)

instance Eq Province where
  p1 == p2 = provinceId p1 == provinceId p2

instance Ord Province where
  p1 <= p2 = provinceId p1 <= provinceId p2

data ProvinceType
         = Inland | Sea | Coastal | BiCoastal
         deriving (Eq, Ord, Show)
                  
data Coast 
         = Coast { coastId :: Int }
         deriving (Eq, Ord, Show)

data UnitType 
         = Army
         | Fleet
         deriving (Eq, Ord, Show)

data Turn = Turn { turnPhase :: Phase
                 , turnYear :: Int }
            deriving (Show, Eq)

data Phase 
         = Spring | Summer | Fall | Autumn | Winter
         deriving (Show, Ord, Eq)

-- | Map topology definitions

data MapDefinition = MapDefinition { mapDefPowers :: [Power]
                                   , mapDefProvinces :: [Province]
                                   , mapDefArmyNodes :: [ProvinceNode]
                                   , mapDefFleetNodes :: [ProvinceNode]
                                   , mapDefAdjacencies :: Map.Map (ProvinceNode, UnitType) [ProvinceNode]
                                   , mapDefProvNodes :: Map.Map Province [ProvinceNode]
                                   , mapDefSupplyInit :: SupplyCOwnerships }
                   deriving (Show, Eq)

  -- | Static game info
data GameInfo = GameInfo { gameInfoMapDef :: MapDefinition
                         , gameInfoTimeout :: Int
                         , gameInfoPower :: Power }
              deriving (Show)


-- | Dynamic game state definitions

data GameState = GameState { gameStateMap :: MapState
                           , gameStateTurn :: Turn }
               deriving (Show)

data MapState = MapState { supplyOwnerships :: SupplyCOwnerships
                         , unitPositions :: UnitPositions }
              deriving (Show, Eq)

type SupplyCOwnerships = Map.Map Power [Province]


data UnitPositions = UnitPositions (Map.Map Power [UnitPosition])
                   | UnitPositionsRet (Map.Map Power [(UnitPosition, Maybe [ProvinceNode])])
                   deriving (Show, Eq)

data UnitPosition = UnitPosition { unitPositionP :: Power
                                 , unitPositionT :: UnitType
                                 , unitPositionLoc :: ProvinceNode }
                  deriving (Eq, Ord, Show)

data ProvinceNode = ProvNode Province
                  | ProvCoastNode Province Coast
                  deriving (Eq, Ord, Show)

-- | Definitions for Orders

data Order = OrderMovement OrderMovement
           | OrderRetreat OrderRetreat
           | OrderBuild OrderBuild
           deriving (Eq, Ord, Show)

data OrderNote = MovementOK
               | NotAdjacent
               | NoSuchProvince
               | NoSuchUnit
               | NotAtSea
               | NoSuchFleet
               | NoSuchArmy
               | NotYourUnit
               | NoRetreatNeeded
               | InvalidRetreatSpace
               | NotYourSC
               | NotEmptySC
               | NotHomeSC
               | NotASC
               | InvalidBuildLocation
               | NoMoreBuildAllowed
               | NoMoreRemovalAllowed
               | NotCurrentSeason
               deriving (Eq, Show)

data OrderResult = Result (Maybe ResultNormal) (Maybe ResultRetreat)
            deriving (Eq, Show)

data ResultNormal = Success
                  | MoveBounced
                  | SupportCut
                  | DisbandedConvoy
                  | NoSuchOrder
                  deriving (Eq, Show)

data ResultRetreat = ResultRetreat
                   deriving (Eq, Show)

-- this is needed so that impementing the three order types is enforced on the type level but SkelBot still has a uniform interface to them
class (Show o) => OrderClass o where
  ordify :: o -> Order
instance OrderClass OrderMovement where
  ordify = OrderMovement
instance OrderClass OrderRetreat where
  ordify = OrderRetreat
instance OrderClass OrderBuild where
  ordify = OrderBuild

-- | Spring term
data OrderMovement = Hold UnitPosition
                   | Move UnitPosition ProvinceNode
                   | SupportHold UnitPosition UnitPosition
                   | SupportMove UnitPosition UnitPosition Province
                   | Convoy UnitPosition UnitPosition ProvinceNode
                   | MoveConvoy UnitPosition ProvinceNode [Province]
                   deriving (Eq, Ord, Show)

-- | Summer term
data OrderRetreat = Retreat UnitPosition ProvinceNode
                  | Disband UnitPosition
                  deriving (Eq, Ord, Show)

-- | Winter term
data OrderBuild = Build UnitPosition
                | Remove UnitPosition
                | Waive Power
                deriving (Eq, Ord, Show)



-- | -------------UNIT TEST DEFS ------------------------------------------                

instance Arbitrary Power where
  arbitrary = frequency [ (1, return Neutral)
                        , (9, return . Power =<< arbitrary)
                        ]


instance Arbitrary MapDefinition where
  arbitrary = do
    p1 <- arbitrary
    p2 <- arbitrary
    ar <- arbitrary
    fl <- arbitrary
    adj <- arbitrary
    pn <- arbitrary
    si <- arbitrary
    return $ MapDefinition { mapDefPowers = p1
                           , mapDefProvinces = p2
                           , mapDefArmyNodes = ar
                           , mapDefFleetNodes = fl
                           , mapDefAdjacencies = adj
                           , mapDefProvNodes = pn
                           , mapDefSupplyInit = si }

-- instance (Ord a, Arbitrary a, Arbitrary b) => Arbitrary (Map.Map a b) where
--   arbitrary = do
--     scos <- listOf1 $ do
--            p <- arbitrary
--            ps <- arbitrary
--            return (p, ps)
--     return . Map.fromList $ scos

instance Arbitrary Province where
  arbitrary = do
    b <- arbitrary
    t <- oneof [ return Inland
               , return Sea
               , return Coastal
               , return BiCoastal ]
    i <- arbitrary
    return $ Province b t i

instance (Ord k, Arbitrary k, Arbitrary v) => Arbitrary (Map.Map k v) where
  arbitrary = do
    kvs <- listOf1 $ liftM2 (,) arbitrary arbitrary
    return $ Map.fromList kvs

-- instance Arbitrary Adjacencies where
--   arbitrary = do
--     adj <- listOf1 $ do
--       p <- arbitrary
--       up <- listOf1 arbitrary
--       return (p, up)
--     return . Adjacencies . Map.fromList $ adj

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
