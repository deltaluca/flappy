{-
 - PATTERN WEIGHTS DATABASE
 - Current version is missing database functionality. I have no real idea how to do this ><
 -
 - Once database functionality is working however, should function for a 1-pattern learning bot. A couple of modifications should enable it to work for 2, and n-pattern bots also. 
 -
 - Currently, I guess database should be a mapping from functions and value
 - to a weight and age
 - (function ID, value) -> (Weight, Age)
 - ie. (Int, Int) -> (Double, Int)
 -}


module Diplomacy.AI.Bots.LearnBot.PatternWeights  (weighOrderSets
                                                  ,randWeightedElem
                                                  ) where

import Diplomacy.AI.Bots.LearnBot.Monad

import Diplomacy.Common.Data
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Common

import Control.Monad
import Control.Monad.Random
import Control.Monad.Trans
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
-- ordering is important!
metrics :: (OrderClass o, MonadIO m) => [OrderMovement -> LearnBrainT o m Int]
metrics = [(\x -> return . bool2Int =<< targNodeFriendly =<< moveOrderToTargProv x)
          ,(\x -> return . bool2Int =<< targNodeOccupied =<< moveOrderToTargProv x)
          ,(\x -> return . bool2Int =<< targNodeIsSupply =<< moveOrderToTargProv x)
          ,(\x -> targNodeAdjUnits            =<< moveOrderToTargProv x)
          ,(\x -> targNodeAdjUnits            =<< moveOrderToOwnProv x)
          ,(\x -> return . mOT2Int                     =<< moveOrderToType x)]

metricIDs = [1..]

moveOrderToOwnProv :: (OrderClass o, MonadIO m) => OrderMovement -> LearnBrainT o m Province
moveOrderToOwnProv order = 
  case order of 
    Hold u            -> return . provNodeToProv . unitPositionLoc $ u
    Move u _          -> return . provNodeToProv . unitPositionLoc $ u
    SupportHold u _   -> return . provNodeToProv . unitPositionLoc $ u  
    SupportMove u _ _ -> return . provNodeToProv . unitPositionLoc $ u
    Convoy u _ _      -> return . provNodeToProv . unitPositionLoc $ u
    MoveConvoy u _ _  -> return . provNodeToProv . unitPositionLoc $ u
 
moveOrderToTargProv :: (OrderClass o, MonadIO m) => OrderMovement -> LearnBrainT o m Province
moveOrderToTargProv order = 
  case order of 
    Hold u            -> return . provNodeToProv . unitPositionLoc $ u
    Move u _          -> return . provNodeToProv . unitPositionLoc $ u
    SupportHold _ u   -> return . provNodeToProv . unitPositionLoc $ u  
    SupportMove _ u _ -> return . provNodeToProv . unitPositionLoc $ u
    Convoy _ u _      -> return . provNodeToProv . unitPositionLoc $ u
    MoveConvoy u _ _  -> return . provNodeToProv . unitPositionLoc $ u

moveOrderToType :: (OrderClass o, MonadIO m) => OrderMovement -> LearnBrainT o m MOrderType
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
-- 

--WTF HASKELL WTF I HATE YOU

updatePatternsGetWeightAge :: Connection -> (Int,Int) -> IO Double
updatePatternsGetWeightAge conn (mid, mval) = do 
  result <- quickQuery' conn "SELECT mid, mval FROM test WHERE mid = ?" [toSql mid] 
  if (length result == 0) 
    then run conn "INSERT INTO test VALUES (?,?,0.5,0)" [toSql mid, toSql mval]
    else run conn "UPDATE test SET age = (age + 1) WHERE mid = ?" [toSql mid]
  weightsResult <- quickQuery' conn "SELECT weight FROM test WHERE mid = ? AND mval = ?" [toSql mid, toSql mval]
  let weight = (fromSql . head $ head weightsResult )::Double
  return weight
  --let x :: Double; x = undefined
--  x


sortGT :: (Double, a) -> (Double, a) ->  Ordering
sortGT (d1,_) (d2,_)
    | d1 < d2 = GT
    | d1 >= d2 = LT


weighOrder :: (MonadIO m, OrderClass o) => OrderMovement -> LearnBrainT o m Double
weighOrder order = do
  metricVals <- sequence [f order | f <- metrics]
  
  let mKeyVals = zip metricIDs metricVals
  conn <- liftIO $ connectSqlite3 "test.db"--hardcoded for now
  --mKeyVals is a list of tubles of mid and mval
  --need to check each pair if it exists in table, if not then add entry with value 0.5 (see below)
  weights <- liftIO ( sequence $ map (updatePatternsGetWeightAge conn) mKeyVals)
  --let weights = map 
  liftIO $ commit conn
  liftIO $ disconnect conn
  -- access database according to function ID and value
  -- if pattern not in database, add entry with value of 0.5 and age 0 and use that
  -- if pattern is in database, take weight and increment age
    
  --let weights :: [Double]; weights = undefined
  -- weights <- dbLookup (zip metrics metricVals)
  
  -- need to consider the weighting of the age
  return $ average weights

weighOrderSet :: (MonadIO m, OrderClass o) => [OrderMovement] -> LearnBrainT o m (Double, [OrderMovement])
weighOrderSet orders = do
  orderSetWeight <- return.average =<< mapM weighOrder orders
  return (orderSetWeight, orders)

weighOrderSets :: (MonadIO m, OrderClass o) => [[OrderMovement]] -> LearnBrainT o m [(Double, [OrderMovement])]
weighOrderSets orderSets = (return . (sortBy sortGT)) =<< mapM weighOrderSet orderSets

randWeightedElem :: (MonadIO m, OrderClass o) => [(Double, [a])] -> LearnBrainT o m [a]
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

targNodeOccupied :: (MonadIO m, OrderClass o) => Province -> LearnBrainT o m Bool 
targNodeOccupied prov = do
  unitMap <- getProvUnitMap
  case prov `Map.lookup` unitMap of
    Nothing -> return False
    _ -> return True

targNodeFriendly :: (MonadIO m, OrderClass o) => Province -> LearnBrainT o m Bool
targNodeFriendly prov = do
  unitMap <- getProvUnitMap
  myPower <- getMyPower
  case prov `Map.lookup` unitMap of
    Just u -> return (myPower == (unitPositionP u))
    _ -> return True --Empty province is friendly I guess?

targNodeIsSupply :: (MonadIO m, OrderClass o) => Province -> LearnBrainT o m Bool 
targNodeIsSupply prov = do
  return $ provinceIsSupply prov

targNodeAdjUnits :: (MonadIO m, OrderClass o) => Province -> LearnBrainT o m Int
targNodeAdjUnits prov = do
  return.length =<< getAdjacentUnits prov

-----------------------------------------------------------------------
-- temporal learning

-- takes the list of ordermovements metrics and the return values that resulted in a successful streak, and applies temporal difference learning over the entire database
applyTDiff :: (MonadIO m, OrderClass o) => [[(Int,Int)]] -> LearnBrainT o m ()
applyTDiff keys = do
  -- keys should be a subset of dbkeys, as new entries should be added as they're not found whilst the game is being played
  let l = length keys
  let dbkeys :: [(Int,Int)]; dbkeys = undefined 
  
  -- Assuming can get some form of equivalences on dbkeys (otherwise can't use elem)
  -- for every set of turn (and set of moves that were used that turn), update the database with the next weight, dependent on whether that move was used that turn and the k value for that turn, ie.
  -- let updates = [[updateDB dbk (getNextWeight (readDB dbk) n (getK n l) (dbk `elem` sucMovs)) | dbk <- dbkeys ] | (n,sucMovs) <- zip [2.. l] keys]

  return ()

-- given the current turn and number of turns, returns a new k to simulate annealing
-- for now just increases linearly as the turns gets closer to the end
-- arbitrary values (from paper), ranges from 1 - 5
getK :: Int -> Int -> Int
getK n l = 1 + (floor (4 * ((fromIntegral n)/(fromIntegral l))))

getNextWeight :: Double -> Int -> Int -> Bool -> Double
getNextWeight prev n k win = (prev*(fromIntegral (n-1)) + (fromIntegral (k*v)))/(fromIntegral (n+k-1))
  where v = bool2Int win
