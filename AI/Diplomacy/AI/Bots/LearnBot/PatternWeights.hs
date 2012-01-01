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

doNothing :: ( Functor m, Monad m, OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m ()
doNothing = do
  return ()

average :: [Double] -> Double
average l = (sum l) / ((fromIntegral.length) l)

weighOrder :: (Functor m, Monad m, OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => OrderMovement -> m Double
weighOrder = undefined

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
