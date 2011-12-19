-- |Common module (convenience functions) for all bots

module Diplomacy.AI.SkelBot.Common( getMyPower
                                  , getMySupplies
                                  , getMyUnits
                                  ) where

import Diplomacy.AI.SkelBot.Brain
import Diplomacy.Common.Data

import Data.Map hiding (map)
import Control.Monad

getMyPower :: OrderClass o => Brain o h Power
getMyPower = asksGameInfo gameInfoPower

getMySupplies :: OrderClass o => Brain o h [Province]
getMySupplies = do
  curMapState <- asksGameState gameStateMap
  myPower <- getMyPower
  let SupplyCOwnerships supplies = supplyOwnerships curMapState
  return (supplies ! myPower)

getMyUnits :: OrderClass o => Brain o h [UnitPosition]
getMyUnits = do
  (GameState mapState (Turn phase _)) <- askGameState
  myPower <- getMyPower
  
  case unitPositions mapState of
    UnitPositions units -> do
      if not $ phase `elem` [Spring, Fall, Winter]
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Spring, Fall, Winter]"
        else return (units ! myPower)
      
    UnitPositionsRet units -> do
      if not $ phase `elem` [Summer, Autumn]
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Summer, Autumn]"
        else return (map fst $ units ! myPower)
