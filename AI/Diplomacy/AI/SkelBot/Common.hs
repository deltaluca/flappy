-- |Common module (convenience functions) for all bots

module Diplomacy.AI.SkelBot.Common( getMyPower
                                  , getSupplies
                                  , getMySupplies
                                  , getUnits
                                  , getMyUnits
                                  ) where

import Diplomacy.AI.SkelBot.Brain
import Diplomacy.Common.Data

import Data.Map hiding (map)
import Control.Monad

-- convention: for every getX there should be a getMyX

getMyPower :: OrderClass o => Brain o h Power
getMyPower = asksGameInfo gameInfoPower

getSupplies :: OrderClass o => Power -> Brain o h [Province]
getSupplies power = do
  curMapState <- asksGameState gameStateMap
  let SupplyCOwnerships supplies = supplyOwnerships curMapState
  return (supplies ! power)

getMySupplies :: OrderClass o => Brain o h [Province]
getMySupplies = getSupplies =<< getMyPower

getUnits :: OrderClass o => Power -> Brain o h [UnitPosition]
getUnits power = do
  (GameState mapState (Turn phase _)) <- askGameState
  
  case unitPositions mapState of
    UnitPositions units -> do
      if not $ phase `elem` [Spring, Fall, Winter]
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Spring, Fall, Winter]"
        else return (units ! power)
      
    UnitPositionsRet units -> do
      if not $ phase `elem` [Summer, Autumn]
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Summer, Autumn]"
        else return (map fst $ units ! power)

getMyUnits :: OrderClass o => Brain o h [UnitPosition]
getMyUnits = getUnits =<< getMyPower
