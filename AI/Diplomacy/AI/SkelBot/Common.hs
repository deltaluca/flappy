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

-- get own power token
getMyPower :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m Power
getMyPower = asksGameInfo gameInfoPower

-- get supplies for a given power
getSupplies :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => Power -> m [Province]
getSupplies power = do
  curMapState <- asksGameState gameStateMap
  let SupplyCOwnerships supplies = supplyOwnerships curMapState
  return (supplies Map.! power)

-- get own supplies
getMySupplies :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m [Province]
getMySupplies = getSupplies =<< getMyPower

-- get units for a given power (special cases depending on regular phase or retreat phase)
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

-- get own units
getMyUnits :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m [UnitPosition]
getMyUnits = getUnits =<< getMyPower

-- get possible retreats
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

-- get adjacent nodes to a given unit
getAdjacentNodes :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => UnitPosition -> m [ProvinceNode]
getAdjacentNodes (UnitPosition _ unitType provNode) = do
  mapDef <- asksGameInfo gameInfoMapDef
  let Adjacencies adjMap = mapDefAdjacencies mapDef
  return $ adjMap Map.! (provNode, unitType)
  
-- pick a random element from a list
randElem :: (MonadRandom m) => [a] -> m a
randElem l = do
  let len = length l
  if len == 0
    then error "randElem called with empty list"
    else return . (l !!) =<< getRandomR (0, len - 1)

-- abstracts a province to just its name (ie. disregarding coasts etc.)
provNodeToProv :: ProvinceNode -> Province
provNodeToProv (ProvNode prov) = prov
provNodeToProv (ProvCoastNode prov _) = prov

-- returns a mapping from provinces to units
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

--------------------------------------------------------
--                Metrics motherfucka                 --
--------------------------------------------------------

-- given a power returns the number of supply centers owned and non-supply centers owned
getProvOcc :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => Power -> m (Int, Int)
getProvOcc power = do
  suppC <- getSupplies power
  units <- getUnits power
  let occupied_prov = map (provNodeToProv . unitPositionLoc) units
  return (length suppC, length (occupied_prov \\ suppC)) 


-- returns a three-tuple of supply center control, (you, enemy, no-one)
getSuppControl :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m (Int, Int, Int)
getSuppControl =
  mapDef <- asksGameInfo gameInfoMapDef

  let provinces = mapDefProvinces mapDef
  let numSupplies = length [1 | p <- provinces, provinceIsSupply p == True]
  
  powerSupplies <- mapM getSupplies (mapDefPowers mapDef)
  let allSupplies = sum $ map length powerSupplies
  let mySupplies = length =<< getMySupplies
  
  return (mySupplies, allSupplies - mySupplies, numSupplies - mySupplies - allSupplies)


-- returns a three-tuple of province occupation around adjacent provinces only
getAdjProvOcc :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => UnitPosition -> m (Int, Int, Int)
getAdjProvOcc unit = do
  provNodes <- getAdjacentNodes unit
  let provs = map provNodeToProv provNodes
  let unitPositions = map (getProvUnitMap Map.lookup) provs
  myPower <- getMyPower
  let ourOcc = length [1 | p <- (map unitPositionP unitpositions), p == myPower]
  let enemyOcc = length unitPositions - ourOcc
  let noOcc = length provs - length unitPositions
  return (noOcc, ourOcc, enemyOcc) 

