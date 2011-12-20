-- |Common module (convenience functions) for all bots

module Diplomacy.AI.SkelBot.Common( getMyPower
                                  , getSupplies
                                  , getMySupplies
                                  , getUnits
                                  , getMyUnits
                                  , getMyRetreats
                                  , getAdjacentNodes
                                  , getProvUnitMap
                                  , randElem
                                  , provNodeToProv
                                  ) where

import Diplomacy.AI.SkelBot.Brain
import Diplomacy.Common.Data

import Data.Maybe
import Control.Monad
import Control.Monad.Random

import qualified Data.Map as Map

getMyPower :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m Power
getMyPower = asksGameInfo gameInfoPower

getSupplies :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => Power -> m [Province]
getSupplies power = do
  curMapState <- asksGameState gameStateMap
  let SupplyCOwnerships supplies = supplyOwnerships curMapState
  return (supplies Map.! power)

getMySupplies :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m [Province]
getMySupplies = getSupplies =<< getMyPower

getUnits :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => Power -> m [UnitPosition]
getUnits power = do
  (GameState mapState (Turn phase _)) <- askGameState
  
  case unitPositions mapState of
    UnitPositions units -> do
      if not $ phase `elem` [Spring, Fall, Winter]
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Spring, Fall, Winter]"
        else return (units Map.! power)
      
    UnitPositionsRet units -> do
      if not $ phase `elem` [Summer, Autumn]
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Summer, Autumn]"
        else return (map fst $ units Map.! power)

getMyUnits :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m [UnitPosition]
getMyUnits = getUnits =<< getMyPower

getMyRetreats :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m [(UnitPosition, [ProvinceNode])]
getMyRetreats = do
  (GameState mapState (Turn phase _)) <- askGameState
                                         
  case unitPositions mapState of
    UnitPositionsRet units -> do
      if not $ phase `elem` [Summer, Autumn]
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Summer, Autumn]"
        else do
        allElems <- return . (units Map.!) =<< getMyPower
        return . mapMaybe (\(a, mb) -> maybe Nothing (\b -> Just (a, b)) mb) $ allElems
    _ -> error $ "getMyRetreats called with UnitPositions"

getAdjacentNodes :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => UnitPosition -> m [ProvinceNode]
getAdjacentNodes (UnitPosition _ unitType provNode) = do
  mapDef <- asksGameInfo gameInfoMapDef
  let Adjacencies adjMap = mapDefAdjacencies mapDef
  return $ adjMap Map.! (provNode, unitType)
  
randElem :: (MonadRandom m) => [a] -> m a
randElem l = do
  let len = length l
  if len == 0
    then error "randElem called with empty list"
    else return . (l !!) =<< getRandomR (0, len - 1)

provNodeToProv :: ProvinceNode -> Province
provNodeToProv (ProvNode prov) = prov
provNodeToProv (ProvCoastNode prov _) = prov

getProvUnitMap :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) =>
                  m (Map.Map Province UnitPosition)
getProvUnitMap = do
  (GameState mapState (Turn phase _)) <- askGameState
  units <- case unitPositions mapState of
    UnitPositions units -> do
      if not $ phase `elem` [Spring, Fall, Winter]
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Summer, Autumn]"
        else return (concat . Map.elems $ units)
      
    UnitPositionsRet units -> do
      if not $ phase `elem` [Summer, Autumn]
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Summer, Autumn]"
        else return (map fst . concat . Map.elems $ units)
    
  foldM (\m unitPos -> return $
                       Map.insert (provNodeToProv $ unitPositionLoc unitPos) unitPos m) Map.empty units