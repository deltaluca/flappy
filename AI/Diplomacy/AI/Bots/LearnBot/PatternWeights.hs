{-
 - PATTERN WEIGHTS DATABASE
 - Current version is missing database functionality. I have no real idea how to do this ><
 -
 - Once database functionality is working however, should function for a 1-pattern learning bot. A couple of modifications should enable it to work for 2, and n-pattern bots also. 
 -}


module Diplomacy.AI.Bots.LearnBot.PatternWeights  (weighOrderSets
                                                  ,randWeightedElem
                                                  ) where

import Diplomacy.Common.Data
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Common

import Control.Monad
import Control.Monad.Random
import Control.Applicative

import System.Random

import Data.Maybe
import Data.List
import Database.HDBC
import Database.HDBC.Sqlite3

import qualified Data.Map as Map

-- arbitrary numberings for the various types of move orders
data MOrderType = THold
                | TMove
                | TSupportHold
                | TSupportMove
                | TConvoy
                | TMoveConvoy
                deriving (Eq, Ord, Show)

mOTTmap :: Map.Map MOrderType Int
mOTTmap = Map.fromList $ zip [THold,TMove,TSupportHold,TSupportMove,TConvoy,TMoveConvoy] [1..] 

mOT2Int :: MOrderType -> Int
mOT2Int = (mOTTmap Map.!)

bool2Int :: Bool -> Int
bool2Int b = if b then 1 else 0

-- metrics in use (YES this is ugly as hell, I have no idea how to neatly tie together half-formed monads though :()
metrics :: (Functor m, Monad m, OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => [(OrderMovement -> m Int)]
metrics = [(\x -> return . bool2Int =<< targNodeFriendly =<< moveOrderToTargProv x)
          ,(\x -> return . bool2Int =<< targNodeOccupied =<< moveOrderToTargProv x)
          ,(\x -> return . bool2Int =<< targNodeIsSupply =<< moveOrderToTargProv x)
          ,(\x -> targNodeAdjUnits            =<< moveOrderToTargProv x)
          ,(\x -> return . bool2Int =<< targNodeFriendly =<< moveOrderToOwnProv x)
          ,(\x -> return . bool2Int =<< targNodeOccupied =<< moveOrderToOwnProv x)
          ,(\x -> return . bool2Int =<< targNodeIsSupply =<< moveOrderToOwnProv x)
          ,(\x -> targNodeAdjUnits            =<< moveOrderToOwnProv x)
          ,(\x -> return . mOT2Int                     =<< moveOrderToType x)]

moveOrderToOwnProv :: (Functor m, Monad m, OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => OrderMovement -> m Province
moveOrderToOwnProv order = 
  case order of 
    Hold u            -> return . provNodeToProv . unitPositionLoc $ u
    Move u _          -> return . provNodeToProv . unitPositionLoc $ u
    SupportHold u _   -> return . provNodeToProv . unitPositionLoc $ u  
    SupportMove u _ _ -> return . provNodeToProv . unitPositionLoc $ u
    Convoy u _ _      -> return . provNodeToProv . unitPositionLoc $ u
    MoveConvoy u _ _  -> return . provNodeToProv . unitPositionLoc $ u
 
moveOrderToTargProv :: (Functor m, Monad m, OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => OrderMovement -> m Province
moveOrderToTargProv order = 
  case order of 
    Hold u            -> return . provNodeToProv . unitPositionLoc $ u
    Move u _          -> return . provNodeToProv . unitPositionLoc $ u
    SupportHold _ u   -> return . provNodeToProv . unitPositionLoc $ u  
    SupportMove _ u _ -> return . provNodeToProv . unitPositionLoc $ u
    Convoy _ u _      -> return . provNodeToProv . unitPositionLoc $ u
    MoveConvoy u _ _  -> return . provNodeToProv . unitPositionLoc $ u

moveOrderToType :: (Functor m, Monad m, OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => OrderMovement -> m MOrderType
moveOrderToType order =
  case order of 
    Hold _            -> return THold 
    Move _ _          -> return TMove
    SupportHold _ _   -> return TSupportHold
    SupportMove _ _ _ -> return TSupportMove
    Convoy _ _ _      -> return TConvoy
    MoveConvoy _ _ _  -> return TMoveConvoy

average :: [Double] -> Double
average l = (sum l) / ((fromIntegral.length) l)

--------------------------------------------------------------------
-- order weighing 

weighOrder :: (Functor m, Monad m, OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => OrderMovement -> m Double
weighOrder order = do
  metricVals <- sequence [f order | f <- metrics]

  -- access database according to function and value
  -- if pattern not in database, add entry with value of 0.5 and use that
  let weights :: [Double]; weights = undefined
  -- weights <- dbLookup (zip metrics metricVals)

  return $ average weights

weighOrderSet :: (Functor m, Monad m, OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => [OrderMovement] -> m (Double, [OrderMovement])
weighOrderSet orders = do
  orderSetWeight <- return.average =<< mapM weighOrder orders
  return (orderSetWeight, orders)

weighOrderSets :: (Functor m, Monad m, OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => [[OrderMovement]] -> m [(Double, [OrderMovement])]
weighOrderSets = return =<< mapM weighOrderSet 

randWeightedElem :: (MonadRandom m) => [(Double, [a])] -> m [a]
randWeightedElem elemWeights = do
  let (weights, results) = unzip elemWeights
  let sumWeights = sum weights
  let cumProb = reverse.scanr1 (+) $ map (/sumWeights) weights
  ranDouble <- getRandomR (0.0,1.0)
  let index = length $ takeWhile (< ranDouble) cumProb
  let len = length results
  if len == 0
    then error "randWeightedElem called with empty list"
    else return $ results !! index

------------------------------------------------------------------------
-- metrics

targNodeOccupied :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => Province -> m Bool 
targNodeOccupied prov = do
  unitMap <- getProvUnitMap
  case prov `Map.lookup` unitMap of
    Nothing -> return False
    _ -> return True

targNodeFriendly :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => Province -> m Bool
targNodeFriendly prov = do
  unitMap <- getProvUnitMap
  myPower <- getMyPower
  case prov `Map.lookup` unitMap of
    Just u -> return (myPower == (unitPositionP u))
    _ -> return True --Empty province is friendly I guess?

targNodeIsSupply :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => Province -> m Bool 
targNodeIsSupply prov = do
  return $ provinceIsSupply prov

targNodeAdjUnits :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => Province -> m Int
targNodeAdjUnits prov = do
  return.length =<< getAdjacentUnits prov
