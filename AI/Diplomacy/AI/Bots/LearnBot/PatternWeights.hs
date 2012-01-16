{-
 - PATTERN WEIGHTS DATABASE FUNCTIONS
-}

{-# LANGUAGE ScopedTypeVariables, EmptyDataDecls, KindSignatures #-}

module Diplomacy.AI.Bots.LearnBot.PatternWeights  (weighOrderSets
                                                  ,randWeightedElem
                                                  ,applyTDiffEnd
                                                  ,applyTDiffTurn
                                                  ,_noOfSCNeededToWin
                                                  ,_trimNum
                                                  ,_dbname
                                                  ,commitPureDB
                                                  ,makeAndFillPureDB
                                                  ,putPureDBAnalysis
                                                  ,getMyDBTable
                                                  ) where

import Diplomacy.AI.Bots.LearnBot.Monad

import Diplomacy.Common.Data
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Common

import Control.Monad
import Control.Monad.Random
import Control.Monad.Trans


import Data.List
import Database.HDBC
import Database.HDBC.Sqlite3

import qualified Data.Map as Map

-- Dummy type kludge
data Dummy o (m :: * -> *)

-----------------------------------------------------------------------
-- Bot-specific variables
-- Trimmed orders, Metrics, nPatterns, Database name, Weighting of applyTDiffTurn, Variance of K

-- Number of orders left after trimming (speeds up evaluation)
_trimNum :: Int
_trimNum = 3

-- database name
_dbname :: String
_dbname = "test.db"

_powtablenames :: [String]
_powtablenames = ["aus","eng","fra","ger","ita","rus","tur"]

-- n pattern weights to use
_npats :: [Int]
_npats = [1,2,3]

-- _c defines the constant that determines how 'strong' the weights are affected
-- Larger _c corresponds to smaller change
_cTurn :: Double
_cTurn = 50.0

_cEnd :: Double
_cEnd = 10.0

-- sets the low (starting) and high (ending) values of k, which varies linearly over the 
-- game period from low to high. k is used as a 'learning temperature'
_lowK :: Double
_lowK = 1.0
_highK :: Double
_highK = 5.0

-- NOT IMPLEMENTED
-- no of supply centres needed to win
_noOfSCNeededToWin :: Int
_noOfSCNeededToWin = 10

-- _metrics to use
-- ordering is important!
_metrics :: (OrderClass o, MonadIO m) => Dummy o m -> [OrderMovement -> LearnBrainT o m Int]
_metrics _ =  [(\x -> return . bool2Int =<< targNodeFriendly =<< moveOrderToTargProv x)
              ,(\x -> return . bool2Int =<< targNodeOccupied =<< moveOrderToTargProv x)
              ,(\x -> return . bool2Int =<< targNodeIsSupply =<< moveOrderToTargProv x)
              ,(\x ->                       targNodeAdjUnits =<< moveOrderToTargProv x)
              ,(\x ->                       targNodeAdjUnits =<< moveOrderToOwnProv x)
              ,(\x -> return . mOT2Int                       =<< moveOrderToType x)]

-- description of each metric
_metrics_desc =  ["[TN friendly]"
                ,"[TN occupied]"
                ,"[TN supply]"
                ,"[TN adj units]"
                ,"[ON adj units]"
                ,"[Own move]"]

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
cantor a b = hopUll (a+1) (b+1) - 1
  where 
   hopUll c d = ((c + d - 2)*(c + d - 1)) `div` 2 + c 

ncant :: [Int] -> Int
ncant [x] = x
ncant l = ncant' l
  where
    ncant' []     = error "ncant' []"
    ncant' [a,b]  = cantor a b
    ncant' (y:ys) = cantor y $ ncant' ys

decantor :: Int ->  [Int]
decantor y = [a - 1, b-1]
  where 
    [a,b] = deHopUll (y + 1)
    deHopUll h = [i, c - i + 2]
      where
        i = h - delt c
        c :: Int
        c = fromIntegral $ floor $ sqrt (fromIntegral (2*h)) - 0.5
        delt x = (x * (1 + x)) `div` 2
    
de_ncant :: Int -> Int -> [Int]
de_ncant 1 x = [x]
de_ncant 2 x = decantor x
de_ncant n x = de_ncant' n x
  where
    de_ncant' 0 _ = error "de_ncant called with 0 dimension"
    de_ncant' n' x' = a : de_ncant (n'-1) a' 
      where
        [a,a'] = decantor x' 
 
combN :: Int -> [a] -> [[a]]
combN 1 l = [[x] | x <- l]
combN n l
  | length l == n = [l]
  | otherwise     = concat [ map (x:) (combN (n-1) xs) | (x:xs) <- getLists n l]

getLists :: Int -> [a] -> [[a]] 
getLists n l = takeWhile ((>= n).length) $ iterate tail l

genPatternDesc :: Pattern -> String
genPatternDesc p = foldl1 (\x y -> x ++ " AND " ++ y) [_metrics_desc !! (i-1) | i <- getMetrics p]

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
_patterns d = zipApply (generatePatterns d _npats) [1..]

--------------------------------------------------------------------
--------------------------------------------------------------------
-- Order weighing and relevant database functions

commitPureDB :: Connection -> PureDB -> String -> IO ()
commitPureDB conn db table = do
  putStrLn "Commiting pure db, deleting table!"
  run conn ("DELETE FROM " ++ table) []
  putStrLn "Inserting values!"
  sequence $ map (\(_,(pid,pval,weight,age)) -> addVal pid pval weight age ) $ Map.toList db
  return ()
  where 
    addVal pid pval weight age = 
      run conn "INSERT INTO test VALUES (?,?,?,?)" [toSql pid, toSql pval, toSql weight, toSql age]

makeAndFillPureDB :: Connection -> String -> IO PureDB
makeAndFillPureDB conn table = do
  dbVals <- dumpDBValues conn table
  return $ Map.fromList $ zip (map (\(x,y,_,_) -> (x,y)) dbVals) dbVals
 
dumpDBValues :: Connection -> String -> IO [(Int,Int,Double,Int)]
dumpDBValues conn table = do
  results <- quickQuery' conn ("SELECT pid, pval, weight, age FROM " ++ table) []
  return $ map (\[a,b,c,d] -> (fromSql a, fromSql b, fromSql c, fromSql d)) results

average :: [Double] -> Double
average l = (sum l) / ((fromIntegral.length) l)

-- given a connection, (pattern ID, pattern value, pattern size), pulls weight
-- from database and returns (weight, age, pattern size)
updatePatternsGetWeightAge :: (MonadIO m, OrderClass o) => (Int,Int,Int) -> LearnBrainT o m (Double,Int,Int)
updatePatternsGetWeightAge (pid, pval, psize) = do 
  hist <- getHistory
  let pureDB = getPureDB hist

  let result = Map.lookup (pid, pval) pureDB
  case result of  -- if not in database, use default value
    Nothing -> do
      putHistory $ LearnHistory (Map.insert (pid,pval) (pid,pval,0.5,1) pureDB) (getHist hist) 
      return (0.5,1,psize)
    Just (_,_,weight,age) -> do
      putHistory $ LearnHistory (Map.insert (pid,pval) (pid,pval,weight,age+1) pureDB) (getHist hist)
      return $ (weight,age,psize)

sortGT :: (Ord a) => a -> a -> Ordering
sortGT = flip compare
-- sortGT :: (Double, a) -> (Double, a) ->  Ordering
-- sortGT (d1,_) (d2,_)
--     | d1 < d2 = GT
--     | d1 >= d2 = LT

weighOrder :: forall o m. (MonadIO m, OrderClass o) => OrderMovement -> LearnBrainT o m (Double,[(Int,Int)])
weighOrder order = do
  keyVals <- sequence [applyPattern p order | p <- _patterns (undefined :: Dummy o m)]
  weightAgeSizes <- mapM updatePatternsGetWeightAge keyVals
  
  -- weights are linearly biased by their ages and pattern size
  let weights =  map (\(weight,age,patSize) -> (weight*(fromIntegral patSize)) + (fromIntegral age)) weightAgeSizes
  return $ (average weights, peelR keyVals) --remove patSize because it is no longer required
    where
      peelR :: [(a,a,a)] -> [(a,a)]
      peelR  = (\(x,y,_) -> zip x y) . unzip3 

weighOrderSet :: (MonadIO m, OrderClass o) => [OrderMovement] -> LearnBrainT o m ((Double, [OrderMovement]),[(Int,Int)])
weighOrderSet orders = do
  orderKeys <- mapM weighOrder orders
  let (weights, keys) = unzip orderKeys
  return ((average weights, orders),concat keys)

-- the all in one "calc weights and do all turn specific pattern stuff" function
weighOrderSets :: (MonadIO m, OrderClass o) => [[OrderMovement]] -> LearnBrainT o m [(Double, [OrderMovement])]
weighOrderSets orderSets = do
  weightKeys <- mapM weighOrderSet orderSets 
  let (weights, keys) = unzip weightKeys
  stateValue <- getStateValue

  hist <- getHistory
  putHistory $ LearnHistory (getPureDB hist) (getHist hist ++ [(stateValue, concat keys)])
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
  (sc, _) <- getProvOcc myPower
  return $ (fromIntegral sc)/(fromIntegral _noOfSCNeededToWin)

--------------------------------------------------------------------
--------------------------------------------------------------------
-- Temporal Difference Learning and relevant database functions

-- apply TDL for turn-by-turn patterns (ie. change in state value observed by those patterns)
-- takes [(stateValue,[Keys])] 
applyTDiffTurn :: PureDB -> [(Double,[(Int,Int)])] -> PureDB
applyTDiffTurn pdb turnValKeys  = 
  foldl (updateDBTurns l) pdb (zip (zip [1..] (init turnKeyVals)) weightCoeffs)
    where
      l = length turnValKeys 
      (stateValues,turnKeyVals) = unzip turnValKeys
      weightCoeffs = evaluateChangeStates stateValues

updateDBTurns :: Int -> PureDB -> ((Int,[(Int,Int)]),(Double -> Double -> Double -> Double)) -> PureDB
updateDBTurns l pdb ((n,turnKeys),weightFu) = foldl (updateDBTurns' n l weightFu) pdb turnKeys

updateDBTurns' :: Int -> Int -> (Double -> Double -> Double -> Double) -> PureDB -> (Int,Int) -> PureDB
updateDBTurns' n l weightFu pdb (pid,pval) = 
    Map.insert (pid,pval) (pid,pval,newWeight,age) pdb
      where
        (_,_,weight,age) = (Map.!) pdb (pid,pval)
        newWeight = weightFu (getK n l) _cTurn weight
  
  
evaluateChangeStates :: [Double] -> [(Double -> Double -> Double -> Double)]
evaluateChangeStates [] = error "evaluateChangeStates []"
evaluateChangeStates [_] = []
evaluateChangeStates (x:x':xs) =
  evaluateChangeState x x' : evaluateChangeStates (x':xs)

-- generates function f :: K -> C -> old_weight -> Double
evaluateChangeState :: Double -> Double -> (Double -> Double -> Double -> Double)  
evaluateChangeState w1 w2 = (\k c ow -> ((ow*c) + k*(vfromD (w2 - w1) ow))/(c+k))

-- helper function, maps -1 -> 1 to 0 -> 1
vfromD :: Double -> Double -> Double
vfromD d w
  | d <= 0    = (d+1)*w
  | otherwise = d*(1-w)+w

-------------------------------------------------

-- apply TDL for endgame patterns (ie. based on whether pattern led to successful game)
applyTDiffEnd :: PureDB -> [[(Int,Int)]] -> PureDB
applyTDiffEnd pdb succTurnKeys =   
  Map.fromList $ map (\(pid,pval,weight,age) -> ((pid,pval),(pid,pval,weight,age))) dbKeyFinalVals
    where 
  -- keys should be a subset of dbkeys, as new entries should be added as they're not found whilst the game is being played
      l = length succTurnKeys
      dbKeyVals = Map.elems pdb 
      (_,dbKeyFinalVals) = foldl (updateWeights l) (1,dbKeyVals) succTurnKeys

updateWeights :: Int -> (Int,[(Int,Int,Double,Int)]) -> [(Int,Int)]  -> (Int,[(Int,Int,Double,Int)])
updateWeights l (n,keyVals) succKeys = (n+1 , map (\(pid,pval,prev,age) -> (pid, pval, getNextWeight prev (getK n l) ((pid,pval) `elem` succKeys), age)) keyVals)

-- generate temperature based on placement in game
getK :: Int -> Int -> Double
getK n l = _lowK + ((_highK - _lowK) * ((fromIntegral n)/(fromIntegral l)))

getNextWeight :: Double -> Double -> Bool -> Double
getNextWeight prev k win = (prev*_cEnd + k*(fromIntegral v))/(k + _cEnd)
  where v = bool2Int win

--------------------------------------------------------------------
--------------------------------------------------------------------
-- Externally used functions

-- randomly pick an element from a list, except introducing bias based on the weight of
-- that element
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

-- get the specific database table to use based on power for this game
getMyDBTable :: (MonadIO m) => Power -> m String
getMyDBTable myPower = do
  return $ _powtablenames !! powerId myPower

-- Pattern weight database analytics
putPureDBAnalysis :: (MonadIO m, OrderClass o) => Dummy o m -> PureDB -> LearnBrainT o m ()
putPureDBAnalysis d pdb = do
  let pidpvals = map (\(pid, pval, weight, _) -> (pid, pval, weight)) $ Map.elems pdb
  let analysis = [(\pat -> (genPatternDesc pat, de_ncant (getN pat) pval, weight)) (_patterns d !! (pid-1)) | (pid,pval,weight) <- pidpvals]
  liftIO $ sequence [(\(desc,val,weight) -> putStrLn (desc ++ " : " ++ (show val) ++ " : " ++ (show weight))) pat | pat <- analysis]
  return ()

