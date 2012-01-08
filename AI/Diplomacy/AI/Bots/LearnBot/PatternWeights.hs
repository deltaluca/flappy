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
                                                  ,applyTDiffEnd
                                                  ,applyTDiffTurn
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

data Pattern = Pattern {  getMetrics :: [Int]
                       ,  getN :: Int
                       ,  getID :: Int }

instance Eq Pattern where
  a == b  = (getID a) == (getID b)

applyPattern :: (OrderClass o, MonadIO m) => Pattern -> OrderMovement -> LearnBrainT o m (Int,Int)
applyPattern patt order = do
  mVals <- sequence [(metrics !! (i-1)) order | i <- getMetrics patt]
  return (getID patt, ncant mVals)

generatePatterns :: [Int] -> [Int -> Pattern]
generatePatterns ns = concat [[(Pattern ms n) | ms <- combN n metricIDs] | n <- ns]

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

moveOrderToType :: (OrderClass o, MonadIO m) => OrderMovement -> LearnBrainT o m MOrderType
moveOrderToType order =
  case order of 
    Hold _            -> return THold 
    Move _ _          -> return TMove
    SupportHold _ _   -> return TSupportHold
    SupportMove _ _ _ -> return TSupportMove
    Convoy _ _ _      -> return TConvoy
    MoveConvoy _ _ _  -> return TMoveConvoy

mOTTmap :: Map.Map MOrderType Int
mOTTmap = Map.fromList $ zip [THold,TMove,TSupportHold,TSupportMove,TConvoy,TMoveConvoy] [1..] 

mOT2Int :: MOrderType -> Int
mOT2Int = (mOTTmap Map.!)

bool2Int :: Bool -> Int
bool2Int b = if b then 1 else 0

-----------------------------------------------------------------
-- Pattern generation

-- ordering is important!
metrics :: (OrderClass o, MonadIO m) => [OrderMovement -> LearnBrainT o m Int]
metrics = [(\x -> return . bool2Int =<< targNodeFriendly =<< moveOrderToTargProv x)
          ,(\x -> return . bool2Int =<< targNodeOccupied =<< moveOrderToTargProv x)
          ,(\x -> return . bool2Int =<< targNodeIsSupply =<< moveOrderToTargProv x)
          ,(\x -> targNodeAdjUnits            =<< moveOrderToTargProv x)
          ,(\x -> targNodeAdjUnits            =<< moveOrderToOwnProv x)
          ,(\x -> return . mOT2Int                     =<< moveOrderToType x)]

-- HACKED, fix later
metricIDs = [1..6] --take (length metrics) [1..]

zipApply :: [a -> b] -> [a] -> [b]
zipApply fs xs = map (\(f,x) -> f x) $ zip fs xs

patterns :: [Pattern]
patterns    = zipApply (generatePatterns [1,2]) [1..]

moveOrderToOwnProv :: (OrderClass o, MonadIO m) => OrderMovement -> LearnBrainT o m Province
moveOrderToOwnProv = 
  return . provNodeToProv . unitPositionLoc . getOMSubjectUnit
 
moveOrderToTargProv :: (OrderClass o, MonadIO m) => OrderMovement -> LearnBrainT o m Province
moveOrderToTargProv =
    return . provNodeToProv . unitPositionLoc . getOMTargetUnit

average :: [Double] -> Double
average l = (sum l) / ((fromIntegral.length) l)

--------------------------------------------------------------------
-- order weighing 
-- 

--WTF HASKELL WTF I HATE YOU

updatePatternsGetWeightAge :: Connection -> (Int,Int) -> IO (Double,Int)
updatePatternsGetWeightAge conn (mid, mval) = do 
  result <- quickQuery' conn "SELECT mid, mval FROM test WHERE mid = ?" [toSql mid] 
  if (length result == 0) 
    then run conn "INSERT INTO test VALUES (?,?,0.5,1)" [toSql mid, toSql mval]
    else run conn "UPDATE test SET age = (age + 1) WHERE mid = ?" [toSql mid]
  weightsResult <- quickQuery' conn "SELECT weight, age FROM test WHERE mid = ? AND mval = ?" [toSql mid, toSql mval]
  return $ (\[x,y] -> (fromSql x, fromSql y)::(Double,Int)) $ head weightsResult

sortGT :: (Double, a) -> (Double, a) ->  Ordering
sortGT (d1,_) (d2,_)
    | d1 < d2 = GT
    | d1 >= d2 = LT

weighOrder :: (MonadIO m, OrderClass o) => OrderMovement -> LearnBrainT o m (Double,[(Int,Int)])
weighOrder order = do
  keyVals <- sequence [applyPattern p order | p <- patterns]
 
  conn <- liftIO $ connectSqlite3 "test.db"--hardcoded for now
  
  weightAges <- liftIO (sequence $ map (updatePatternsGetWeightAge conn) keyVals)
  
  liftIO $ commit conn
  liftIO $ disconnect conn
 
  -- weights are linearly biased by their ages 
  let weights =  map (\(x,y) -> x + (fromIntegral y)) weightAges

  -- need to consider the weighting of the age
  return $ (average weights,keyVals)

weighOrderSet :: (MonadIO m, OrderClass o) => [OrderMovement] -> LearnBrainT o m ((Double, [OrderMovement]),[(Int,Int)])
weighOrderSet orders = do
  orderKeys <- mapM weighOrder orders
  let (weights, keys) = unzip orderKeys
  return ((average weights, orders),concat keys)

weighOrderSets :: (MonadIO m, OrderClass o) => [[OrderMovement]] -> LearnBrainT o m [(Double, [OrderMovement])]
weighOrderSets orderSets = do
  hist <- getHistory
  weightKeys <- mapM weighOrderSet orderSets
  let (weights, keys) = unzip weightKeys
  let stateValue :: Double; stateValue = undefined
  putHistory (hist ++ [(stateValue, concat keys)])
  (return . (sortBy sortGT)) weights

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

applyTDiffTurn :: [(Double,[(Int,Int)])] -> IO ()
applyTDiffTurn turnValMetrics = undefined
 -- dbKeyVals <- getAllDBValues 

-- generates coefficient to alter weights
evaluateChangeState :: Double -> Double -> Double  
evaluateChangeState preWeight postWeight = undefined

applyTDiffEnd :: [[(Int,Int)]] -> IO ()
applyTDiffEnd succTurnKeys = do
  -- keys should be a subset of dbkeys, as new entries should be added as they're not found whilst the game is being played
  let l = length succTurnKeys
  dbKeyVals <- getAllDBValues
  let (_,dbKeyFinalVals) = foldl (updateWeights l) (1,dbKeyVals) succTurnKeys
  updateDB dbKeyFinalVals 
  return ()

getAllDBValues :: IO [((Int,Int),Double)]
getAllDBValues = do
  conn <- connectSqlite3 "test.db"
  results <- quickQuery' conn "SELECT mid, mval, weight FROM test" []
  commit conn
  disconnect conn
  return $ map convListToTuple results
  
convListToTuple :: [SqlValue] -> ((Int,Int),Double)
convListToTuple [s1,s2,s3] = ((fromSql s1, fromSql s2),fromSql s3)

updateWeights :: Int -> (Int,[((Int,Int),Double)]) -> [(Int,Int)]  -> (Int,[((Int,Int),Double)])
updateWeights l (n,keyVals) succKeys = (n+1 , map (\(key,prev) -> (key, getNextWeight prev (n+1) (getK n l) (key `elem` succKeys))) keyVals)

updateDB :: [((Int,Int),Double)] -> IO ()
updateDB finalVals = do
    conn <- connectSqlite3 "test.db"
    sequence $ map (\((mid,mval),weight) -> 
                         run conn "UPDATE test SET weight = ? WHERE mid = ? AND mval = ?" [toSql weight, toSql mid, toSql mval])
               finalVals
    commit conn
    disconnect conn

-- given the current turn and number of turns, returns a new k to simulate annealing
-- for now just increases linearly as the turns gets closer to the end
-- arbitrary values (from paper), ranges from 1 - 5
getK :: Int -> Int -> Int
getK n l = 1 + (floor (4 * ((fromIntegral n)/(fromIntegral l))))

getNextWeight :: Double -> Int -> Int -> Bool -> Double
getNextWeight prev n k win = (prev*(fromIntegral (n-1)) + (fromIntegral (k*v)))/(fromIntegral (n+k-1))
  where v = bool2Int win
