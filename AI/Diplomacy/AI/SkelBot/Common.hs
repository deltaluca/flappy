-- |Common module (convenience functions) for all bots

-- use flexible contexts to restrict certain functions to a specific phase in the type level!(see getMyRetreats)
{-# LANGUAGE FlexibleContexts #-}

module Diplomacy.AI.SkelBot.Common( getMyPower
                                  , getSupplies
                                  , getMySupplies
                                  , getHomeSupplies
                                  , getMyHomeSupplies
                                  , getUnits
                                  , getMyUnits
                                  , getMyRetreats
                                  , getAdjacentNodes
                                  , getAdjacentUnits
                                  , getAllAdjacentNodes
                                  , getAllAdjacentNodes2
                                  , getProvUnitMap
                                  , getProvNodeUnitMap
                                  , getSupplyPowerMap
                                  , getSupplyPowerMapNoUno
                                  , getAllProvs
                                  , getAllProvNodes
                                  , randElem
                                  , provNodeToProv
                                  , noUno
                                  , (!)
                                  ) where

import Diplomacy.AI.SkelBot.Brain
import Diplomacy.Common.Data

import Data.Maybe
import Data.List
import Control.Applicative
import Control.Monad
import Control.Monad.Random

import qualified Data.Map as Map

(!) :: (Ord a) => Map.Map a [b] -> a -> [b]
mp ! i = maybe [] id (Map.lookup i mp)

-- get own power token
getMyPower :: (MonadGameKnowledge h m) => m Power
getMyPower = asksGameInfo gameInfoPower

-- get supplies for a given power
getSupplies :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => Power -> m [Province]
getSupplies power = do
  curMapState <- asksGameState gameStateMap
  let supplies = supplyOwnerships curMapState
  return $ maybe [] id (Map.lookup power supplies)

-- get own supplies
getMySupplies :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m [Province]
getMySupplies = getSupplies =<< getMyPower

getHomeSupplies :: (MonadGameKnowledge h m) =>
                   Power -> m [Province]
getHomeSupplies power = do
  mapDef <- asksGameInfo gameInfoMapDef
  let initscs = mapDefSupplyInit mapDef
  return (initscs ! power)

getMyHomeSupplies :: (MonadGameKnowledge h m) => m [Province]
getMyHomeSupplies = getHomeSupplies =<< getMyPower

-- get units for a given power (special cases depending on regular phase or retreat phase)
getUnits :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => Power -> m [UnitPosition]
getUnits power = do
  (GameState mapState (Turn phase _)) <- askGameState
  
  case unitPositions mapState of
    UnitPositions units -> do
      if not $ phase `elem` [Spring, Fall, Winter]
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Spring, Fall, Winter]"
        else return (maybe [] id (Map.lookup power units))
      
    UnitPositionsRet units -> do
      if not $ phase `elem` [Summer, Autumn]
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Summer, Autumn]"
        else return (map fst $ maybe [] id (Map.lookup power units))

-- get own units
getMyUnits :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m [UnitPosition]
getMyUnits = getUnits =<< getMyPower

-- get possible retreats
getMyRetreats :: (MonadBrain OrderRetreat m, MonadGameKnowledge h m) => m [(UnitPosition, [ProvinceNode])]
getMyRetreats = do
  (GameState mapState (Turn phase _)) <- askGameState
                                         
  case unitPositions mapState of
    UnitPositionsRet units -> do
      if not $ phase `elem` [Summer, Autumn]
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Summer, Autumn]"
        else do
        allElems <- return . maybe [] id . flip Map.lookup units =<< getMyPower
        return . mapMaybe (\(a, mb) -> maybe Nothing (\b -> Just (a, b)) mb) $ allElems
    _ -> error $ "getMyRetreats called with UnitPositions"

-- get adjacent nodes to a given unit
getAdjacentNodes :: (MonadGameKnowledge h m) => UnitPosition -> m [ProvinceNode]
getAdjacentNodes (UnitPosition _ unitType provNode) = do
  mapDef <- asksGameInfo gameInfoMapDef
  let Adjacencies adjMap = mapDefAdjacencies mapDef
  return $ adjMap ! (provNode, unitType)

-- gets all adjacent nodes to a given province
getAllAdjacentNodes :: (MonadGameKnowledge h m) => Province -> m [ProvinceNode]
getAllAdjacentNodes prov = do
  mapDef <- asksGameInfo gameInfoMapDef
  let Adjacencies adjMap = mapDefAdjacencies mapDef
      provNodes = mapDefProvNodes mapDef ! prov
      nodeUnits = liftM2 (,) provNodes [Army, Fleet]
  return $ foldl1 union . map (adjMap !) $ nodeUnits

-- gets all adjacent nodes to a given provinceNode
getAllAdjacentNodes2 :: (MonadGameKnowledge h m) => ProvinceNode -> m [ProvinceNode]
getAllAdjacentNodes2 provNode = do
  mapDef <- asksGameInfo gameInfoMapDef
  let Adjacencies adjMap = mapDefAdjacencies mapDef
  return $ (adjMap ! (provNode, Army)) `union` (adjMap ! (provNode, Fleet))

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
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Spring, Fall, Winter]"
        else return (concat . Map.elems $ units)
      
    UnitPositionsRet units -> do
      if not $ phase `elem` [Summer, Autumn]
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Summer, Autumn]"
        else return (map fst . concat . Map.elems $ units)
    
  foldM (\m unitPos -> return $
                       Map.insert (provNodeToProv $ unitPositionLoc unitPos) unitPos m) Map.empty units

-- returns a mapping from provinceNodes to units
getProvNodeUnitMap :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) =>
                  m (Map.Map ProvinceNode UnitPosition)
getProvNodeUnitMap = do
  (GameState mapState (Turn phase _)) <- askGameState
  units <- case unitPositions mapState of
    UnitPositions units -> do
      if not $ phase `elem` [Spring, Fall, Winter]
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Spring, Fall, Winter]"
        else return (concat . Map.elems $ units)
      
    UnitPositionsRet units -> do
      if not $ phase `elem` [Summer, Autumn]
        then error $ "Wrong Phase (Got " ++ show phase ++ ", expected [Summer, Autumn]"
        else return (map fst . concat . Map.elems $ units)
    
  foldM (\m unitPos -> return $
                       Map.insert (unitPositionLoc unitPos) unitPos m) Map.empty units

getSupplyPowerMap :: (OrderClass o, MonadBrain o m,
                      MonadGameKnowledge h m) => m (Map.Map Province Power)
getSupplyPowerMap = do
  curMapState <- asksGameState gameStateMap
  let supplies = supplyOwnerships curMapState
  return . Map.foldlWithKey
    (\mp pow prs -> foldl (\mp pr -> Map.insert pr pow mp) mp prs) Map.empty $ supplies

getSupplyPowerMapNoUno :: (OrderClass o, MonadBrain o m,
                           MonadGameKnowledge h m) => m (Map.Map Province Power)
getSupplyPowerMapNoUno = do
  curMapState <- asksGameState gameStateMap
  let supplies = noUno (supplyOwnerships curMapState)
  return . Map.foldlWithKey
    (\mp pow prs -> foldl (\mp pr -> Map.insert pr pow mp) mp prs) Map.empty $ supplies

getAdjacentUnits :: (OrderClass o, MonadBrain o m,
                     MonadGameKnowledge h m) => Province -> m [UnitPosition]
getAdjacentUnits prov = do
  provNodeUnitMap <- getProvNodeUnitMap
  adjNodes <- getAllAdjacentNodes prov
  return $ mapMaybe (`Map.lookup` provNodeUnitMap) adjNodes

getAllProvs :: (Functor m, OrderClass o, MonadBrain o m,
                MonadGameKnowledge h m) => m [Province]
getAllProvs = mapDefProvinces <$> asksGameInfo gameInfoMapDef

getAllProvNodes :: (Functor m, OrderClass o, MonadBrain o m,
                    MonadGameKnowledge h m) => m [ProvinceNode]
getAllProvNodes = do
  allProvs <- getAllProvs
  p2pn <- mapDefProvNodes <$> asksGameInfo gameInfoMapDef
  return $ concatMap (p2pn Map.!) allProvs

noUno :: Map.Map Power a -> Map.Map Power a
noUno = Map.delete Neutral

{-
-- Generates all legal orders only involving own units
genLegalOrders :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => 
							(Map.Map UnitPosition [OrderMovement]) -> UnitPosition -> m (Map.Map UnitPosition [OrderMovement])
genLegalOrders currOrders unitPos = do
  adjacentNodes <- getAdjacentNodes unitPos
  provUnitMap <- getProvUnitMap
  myPower <- getMyPower
  friendlies <- return.(filter (/= unitPos)) =<< getMyUnits

  -- possible support moves
  let supportMoves =  concat [map ((SupportMove unitPos otherUnit).provNodeToProv) $ (intersect adjacentNodes) =<< (getAdjacentNodes otherUnit) 
                      | otherUnit <- friendlies]
   
  let adjUnits =  [ otherUnit
        	        | otherPos <- adjacentNodes
                  , otherUnit <- maybeToList $
                    provNodeToProv otherPos `Map.lookup` provUnitMap
        	        , unitPositionP otherUnit == myPower ] 

  -- possible support holds (ie. just adjacent friendlies)
  let supportHolds =  [ SupportHold unitPos otherUnit
        	            | otherUnit <- adjUnits]

  -- possible simple moves
  let moveMoves = map (Move unitPos) adjacentNodes

  -- hold move
  let holdMoves = [Hold unitPos]

  -- TODO: create convoy moves here and add them to allMoves below
  -- let convoyMoves = ...
  
  -- add all possible moves for this unit into the map
  let allMoves = supportMoves ++ moveMoves ++ holdMoves ++ supportHolds
  return $ Map.insert unitPos allMoves currOrders
-}
--------------------------------------------------------
--                Metrics                             --
--------------------------------------------------------


-- given a power returns the number of supply centers owned and non-supply centers occupied
getProvOcc :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => Power -> m (Int, Int)
getProvOcc power = do
   suppC <- getSupplies power
   units <- getUnits power
   let occupied_prov = map (provNodeToProv . unitPositionLoc) units
   return (length suppC, length (occupied_prov \\ suppC)) 


-- returns a three-tuple of supply center control, (you, enemy, no-one)
getSuppControl :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m (Int, Int, Int)
getSuppControl = do
  mapDef <- asksGameInfo gameInfoMapDef

  let provinces = mapDefProvinces mapDef
  let numSupplies = length [1 | p <- provinces, provinceIsSupply p == True]
  
  powerSupplies <- mapM getSupplies (mapDefPowers mapDef)
  let allSupplies = sum $ map length powerSupplies
  mySupplies <- return . length =<< getMySupplies
  
  return (mySupplies, allSupplies - mySupplies, numSupplies - mySupplies - allSupplies)


-- returns a three-tuple of province occupation around adjacent provinces only
getAdjProvOcc :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => UnitPosition -> m (Int, Int, Int)
getAdjProvOcc unit = do
  provNodes <- getAdjacentNodes unit
  let provs = map provNodeToProv provNodes
  unitPositions <- getMyUnits
  myPower <- getMyPower
  let ourOcc = length [1 | p <- (map unitPositionP unitPositions), p == myPower]
  let enemyOcc = length unitPositions - ourOcc
  let noOcc = length provs - length unitPositions
  return (noOcc, ourOcc, enemyOcc) 

