{- # Inference module, functions related to inferring motives #
 -
-}



module Diplomacy.AI.Bots.Inferrence  (
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

----------------------------------------------------------------------------
-- # Looking for factors in a state # --
--
getUnitAttacks :: (Functor m, Monad m, OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => (Map.Map Power [UnitPosition]) -> UnitPosition -> [UnitPosition]
getUnitAttacks pPos unit = do
  myPower <- getMyPower
  unitProv <- provNodeToProv . unitPositionLoc unit
  adjUnits <- getAdjacentUnits unitProv
  adjNodes <- getAdjacentNodes unit
 
  filterM (\u -> return . elem (unitPositionLoc u) adjNodes) adjUnits

getPossibleAttacks :: (Functor m, Monad m, OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => (Map.Map Power [UnitPosition]) -> Power -> [*Conflicts*]
getPossibleAttacks pPos pow = do
  enemyUnits <- pPos Map.! pow
   
  possibleConflicts = [(unit, getUnitAttacks pPos unit) | unit <- enemyUnits]

  return possibleConflicts

-- weighAttacks
--
-- getSupplyAcquisition
--

---------------------------------------------------------------------------
-- # Looking for factors in a change of state # --
--
-- netMovement?
--
-- getConflicts 
--

---------------------------------------------------------------------------
-- # Inferrence database update functions # --
--
-- evaluateEvidence
