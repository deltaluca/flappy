{-
 - PATTERN WEIGHTS DATABASE FUNCTIONS
-}

{-# LANGUAGE ScopedTypeVariables #-}

module Diplomacy.AI.Bots.LearnBot.PatternWeights  (weighOrderSets
                                                  ,randWeightedElem
                                                  ,applyTDiffEnd
                                                  ,applyTDiffTurn
                                                  ,_noOfSCNeededToWin
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

import Data.List
import Database.HDBC
import Database.HDBC.Sqlite3

import qualified Data.Map as Map

-- Dummy type kludge
data Dummy o m = Dummy (m o)

-----------------------------------------------------------------------
-- Bot-specific variables
-- Metrics, nPatterns, Database name, Weighting of applyTDiffTurn, Variance of K

-- database name
_dbname :: String
_dbname = "test.db"

-- n pattern weights to use
_npats :: [Int]
_npats = [1,2]

-- _c defines the constant that determines how 'strong' the weights are affected
-- Larger _c corresponds to smaller change
_c :: Double
_c = 10.0

-- sets the low (starting) and high (ending) values of k, which varies linearly over the 
-- game period from low to high. k is used as a 'learning temperature'
_lowK :: Double
_lowK = 1.0
_highK :: Double
_highK = 5.0

-- no of supply centres needed to win
_noOfSCNeededToWin :: Int
_noOfSCNeededToWin = 18

-- _metrics to use
-- ordering is important!
_metrics :: (OrderClass o, MonadIO m) => Dummy o m -> [OrderMovement -> LearnBrainT o m Int]
_metrics _ = [(\x -> return . bool2Int =<< targNodeFriendly =<< moveOrderToTargProv x)
            ,(\x -> return . bool2Int =<< targNodeOccupied =<< moveOrderToTargProv x)
            ,(\x -> return . bool2Int =<< targNodeIsSupply =<< moveOrderToTargProv x)
            ,(\x ->                       targNodeAdjUnits =<< moveOrderToTargProv x)
            ,(\x ->                       targNodeAdjUnits =<< moveOrderToOwnProv x)
            ,(\x -> return . mOT2Int                       =<< moveOrderToType x)]

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Pattern specific functions

data Pattern = Pattern {  getMetrics :: [Int]
                       ,  getN :: Int
                       ,  getID :: Int }

applyPattern :: (OrderClass o, MonadIO m) => Pattern -> OrderMovement -> LearnBrainT o m (Int,Int,Int)
applyPattern patt order = do
  mVals <- sequence [(_metrics undefined !! (i-1)) order | i <- getMetrics patt]
  return (getID patt, ncant mVals, getN patt)

generatePatterns :: (OrderClass o, MonadIO m) => Dummy o m -> [Int] -> [Int -> Pattern]
generatePatterns d ns = concat [[(Pattern ms n) | ms <- combN n (metricIDs d)] | n <- ns]

cantor :: Int -> Int -> Int
cantor a b = floor (fromIntegral ((a + b)*(a + b + 1)) /2) + b

ncant :: [Int] -> Int
ncant [x] = x
ncant l = ncant' (length l) l
  where
    ncant' 2 [a,b]  = cantor a b
    ncant' n (x:xs) = cantor x $ ncant' (n-1) xs

combN :: Int -> [a] -> [[a]]
combN 1 l = [[x] | x <- l]
combN n l
  | length l == n = [l]
  | otherwise     = concat [ map (x:) (combN (n-1) xs) | (x:xs) <- getLists n l]

getLists :: Int -> [a] -> [[a]] 
getLists n l = takeWhile ((>= n).length) $ iterate tail l

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Metric specific stuff

-- arbitrary numberings for the various types of move orders
data MOrderType = THold
                | TMove
                | TSupportHold
                | TSupportMove
                | TConvoy
                | TMoveConvoy
                deriving (Eq, Ord, Show)

moveOrderToType :: (OrderClass o, MonadIO m) => OrderMovement -> LearnBrainT o m MOrderType
moveOrderToType order =
  case order of 
    Hold _            -> return THold 
    Move _ _          -> return TMove
    SupportHold _ _   -> return TSupportHold
    SupportMove _ _ _ -> return TSupportMove
    Convoy _ _ _      -> return TConvoy
    MoveConvoy _ _ _  -> return TMoveConvoy

moveOrderToOwnProv :: (OrderClass o, MonadIO m) => OrderMovement -> LearnBrainT o m Province
moveOrderToOwnProv = 
  return . provNodeToProv . unitPositionLoc . getOMSubjectUnit
 
moveOrderToTargProv :: (OrderClass o, MonadIO m) => OrderMovement -> LearnBrainT o m Province
moveOrderToTargProv =
    return . provNodeToProv . unitPositionLoc . getOMTargetUnit

mOTTmap :: Map.Map MOrderType Int
mOTTmap = Map.fromList $ zip [THold,TMove,TSupportHold,TSupportMove,TConvoy,TMoveConvoy] [1..] 

mOT2Int :: MOrderType -> Int
mOT2Int = (mOTTmap Map.!)

bool2Int :: Bool -> Int
bool2Int b = if b then 1 else 0

-----------------------------------------------------------------
-----------------------------------------------------------------
-- Pattern generation functions

metricIDs :: (OrderClass o, MonadIO m) => Dummy o m -> [Int]
metricIDs d = take (length (_metrics d)) [1..]

zipApply :: [a -> b] -> [a] -> [b]
zipApply fs xs = map (\(f,x) -> f x) $ zip fs xs

_patterns :: (OrderClass o, MonadIO m) => Dummy o m -> [Pattern]
_patterns d  = zipApply (generatePatterns d _npats) [1..]

--------------------------------------------------------------------
--------------------------------------------------------------------
-- Order weighing and relevant database functions

average :: [Double] -> Double
average l = (sum l) / ((fromIntegral.length) l)

-- given a connection, (pattern ID, pattern value, pattern size), pulls weight
-- from database and returns (weight, age, pattern size)
updatePatternsGetWeightAge :: Connection -> (Int,Int,Int) -> IO (Double,Int,Int)
updatePatternsGetWeightAge conn (pid, pval, psize) = do 
  result <- quickQuery' conn "SELECT pid, pval FROM test WHERE pid = ?" [toSql pid] 
  if (length result == 0) -- if not in database, use default value
    then run conn "INSERT INTO test VALUES (?,?,0.5,1)" [toSql pid, toSql pval]
    else run conn "UPDATE test SET age = (age + 1) WHERE pid = ?" [toSql pid]
  weightsResult <- quickQuery' conn "SELECT weight, age FROM test WHERE pid = ? AND pval = ?" [toSql pid, toSql pval]
  return $ (\[x,y] -> (fromSql x, fromSql y, psize)::(Double,Int,Int)) $ head weightsResult

sortGT :: (Double, a) -> (Double, a) ->  Ordering
sortGT (d1,_) (d2,_)
    | d1 < d2 = GT
    | d1 >= d2 = LT

weighOrder :: forall o m. (MonadIO m, OrderClass o) => OrderMovement -> LearnBrainT o m (Double,[(Int,Int)])
weighOrder order = do
  keyVals <- sequence [applyPattern p order | p <- _patterns (undefined :: Dummy o m)]
  conn <- liftIO $ connectSqlite3 _dbname
  weightAgeSizes <- liftIO (sequence $ map (updatePatternsGetWeightAge conn) keyVals)
  
  liftIO $ commit conn
  liftIO $ disconnect conn
 
  -- weights are linearly biased by their ages and pattern size
  let weights =  map (\(weight,age,patSize) -> (weight*(fromIntegral patSize)) + (fromIntegral age)) weightAgeSizes
  return $ (average weights, peelR keyVals) --remove patSize because it is no longer required
    where
      peelR :: [(a,a,a)] -> [(a,a)]
      peelR  = (\(x,y,z) -> zip x y) . unzip3 

weighOrderSet :: (MonadIO m, OrderClass o) => [OrderMovement] -> LearnBrainT o m ((Double, [OrderMovement]),[(Int,Int)])
weighOrderSet orders = do
  orderKeys <- mapM weighOrder orders
  let (weights, keys) = unzip orderKeys
  return ((average weights, orders),concat keys)

-- the all in one "calc weights and do all turn specific pattern stuff" function
weighOrderSets :: (MonadIO m, OrderClass o) => [[OrderMovement]] -> LearnBrainT o m [(Double, [OrderMovement])]
weighOrderSets orderSets = do
  hist <- getHistory

  weightKeys <- mapM weighOrderSet orderSets
  let (weights, keys) = unzip weightKeys
  stateValue <- getStateValue

  putHistory (hist ++ [(stateValue, concat keys)])
  (return . (sortBy sortGT)) weights


--------------------------------------------------------------------
--------------------------------------------------------------------
-- Pre-defined metrics

-- unit specifc metrics ---------

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

-- metrics for calculating state value of a given turn -------
--
getStateValue :: (MonadIO m, OrderClass o) => LearnBrainT o m Double
getStateValue = do
   getSupplyCentresValue
  
getSupplyCentresValue ::  (MonadIO m, OrderClass o) => LearnBrainT o m Double
getSupplyCentresValue = do
  myPower <- getMyPower
  (sc, nonsc) <- getProvOcc myPower
  return $ (fromIntegral sc)/(fromIntegral _noOfSCNeededToWin)

--------------------------------------------------------------------
--------------------------------------------------------------------
-- Temporal Difference Learning and relevant database functions

-- apply TDL for turn-by-turn patterns (ie. change in state value observed by those patterns)
-- takes [(stateValue,[Keys])] 
applyTDiffTurn :: [(Double,[(Int,Int)])] -> IO ()
applyTDiffTurn turnValKeys = do
  let l = length turnValKeys 
  let (stateValues,turnKeyVals) = unzip turnValKeys
  let weightCoeffs = evaluateChangeStates stateValues
  sequence $ zipWith (updateDBTurns l) (zip [1..] (init turnKeyVals)) weightCoeffs
  return ()

updateDBTurns :: Int -> (Int,[(Int,Int)])-> (Double -> Double -> Double -> Double) -> IO ()
updateDBTurns l (n,turnKeys) weightFu = do
   conn <- connectSqlite3 _dbname
   sequence $ map (updateDBTurns' conn n l weightFu) turnKeys
   commit conn
   disconnect conn

updateDBTurns' :: Connection -> Int -> Int -> (Double -> Double -> Double -> Double) -> (Int,Int) -> IO ()
updateDBTurns' conn n l weightFu (pid,pval) = do
  weight <- (return .fromSql . head . head) =<< quickQuery' conn "SELECT weight FROM test WHERE pid = ? AND pval = ?" [toSql pid, toSql pval]
  let newWeight = weightFu (getK n l) _c weight
  run conn "UPDATE test SET weight = weight WHERE pid = ? AND pval = ?" [toSql newWeight, toSql pid, toSql pval]
  return ()
  
evaluateChangeStates :: [Double] -> [(Double -> Double -> Double -> Double)]
evaluateChangeStates [x] = []
evaluateChangeStates (x:x':xs) =
  evaluateChangeState x x' : evaluateChangeStates (x':xs)

-- generates function f :: K -> C -> old_weight -> Double
evaluateChangeState :: Double -> Double -> (Double -> Double -> Double -> Double)  
evaluateChangeState w1 w2 = (\k c ow -> ((ow*c) + k*(vfromD (w2 - w1) ow))/(c+k))

-- helper function, maps -1 -> 1 to 0 -> 1
vfromD :: Double -> Double -> Double
vfromD d w
  | d <= 0  = (d+1)*w
  | d > 0   = d*(1-w)+w

-------------------------------------------------

-- apply TDL for endgame patterns (ie. based on whether pattern led to successful game)
applyTDiffEnd :: [[(Int,Int)]] -> IO ()
applyTDiffEnd succTurnKeys = do
  -- keys should be a subset of dbkeys, as new entries should be added as they're not found whilst the game is being played
  let l = length succTurnKeys
  dbKeyVals <- getAllDBValues
  let (_,dbKeyFinalVals) = foldl (updateWeights l) (1,dbKeyVals) succTurnKeys
  updateDB dbKeyFinalVals 

getAllDBValues :: IO [((Int,Int),Double)]
getAllDBValues = do
  conn <- connectSqlite3 _dbname
  results <- quickQuery' conn "SELECT pid, pval, weight FROM test" []
  commit conn
  disconnect conn
  return $ map convListToTuple results
  
convListToTuple :: [SqlValue] -> ((Int,Int),Double)
convListToTuple [s1,s2,s3] = ((fromSql s1, fromSql s2),fromSql s3)

updateWeights :: Int -> (Int,[((Int,Int),Double)]) -> [(Int,Int)]  -> (Int,[((Int,Int),Double)])
updateWeights l (n,keyVals) succKeys = (n+1 , map (\(key,prev) -> (key, getNextWeight prev (n+1) (getK n l) (key `elem` succKeys))) keyVals)

updateDB :: [((Int,Int),Double)] -> IO ()
updateDB finalVals = do
    conn <- connectSqlite3 _dbname
    sequence $ map (\((pid,pval),weight) -> 
                         run conn "UPDATE test SET weight = ? WHERE pid = ? AND pval = ?" [toSql weight, toSql pid, toSql pval])
               finalVals
    commit conn
    disconnect conn

-- generate temperature based on placement in game
getK :: Int -> Int -> Double
getK n l = _lowK + ((_highK - _lowK) * ((fromIntegral n)/(fromIntegral l)))

getNextWeight :: Double -> Int -> Double -> Bool -> Double
getNextWeight prev n k win = (prev*(fromIntegral (n-1)) + k*(fromIntegral v))/(k + fromIntegral (n-1))
  where v = bool2Int win

--------------------------------------------------------------------
--------------------------------------------------------------------
-- Externally used functions

randWeightedElem :: (MonadIO m, OrderClass o) => [(Double, [a])] -> LearnBrainT o m [a]
randWeightedElem elemWeights = do
  let (weights, results) = unzip elemWeights
  let sumWeights = sum weights
  let cumProb = scanl1 (+) $ map (/sumWeights) weights
  ranDouble <- getRandomR (0.0,1.0)
  let index = length $ takeWhile (< ranDouble) cumProb
  let len = length results
  if len == 0
    then error "randWeightedElem called with empty list"
    else return $ results !! index
