-- |Common module (convenience functions) for all bots

module Diplomacy.AI.SkelBot.Common( getMyPower
                                  , getSupplies
                                  , getMySupplies
                                  , getHomeSupplies
                                  , getMyHomeSupplies
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
  return $ maybe [] id (Map.lookup power supplies)

-- get own supplies
getMySupplies :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m [Province]
getMySupplies = getSupplies =<< getMyPower

getHomeSupplies :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) =>
                   Power -> m [Province]
getHomeSupplies power = do
  mapDef <- asksGameInfo gameInfoMapDef
  let SupplyCOwnerships initscs = mapDefSupplyInit mapDef
  return (initscs Map.! power)

getMyHomeSupplies :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m [Province]
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
getMyRetreats :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m [(UnitPosition, [ProvinceNode])]
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

-- Currently a copy from random. Need to generalise and make it return a mapping from 
-- units to possible orders (so that, for instance, all possible move combinations can be generated)
{-genLegalOrders :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => (Map.Map UnitPosition [OrderMovement]) -> 
		  UnitPosition -> m (Map.Map UnitPosition [OrderMovement])
genLegalOrders currOrders unitPos = do
  adjacentNodes <- getAdjacentNodes unitPos

  -- nodes being moved to by other units
  let movedTo = mapMaybe (\mo -> case mo of
                             Move u node -> Just (u, node)
                             _ -> Nothing) currOrders
  
  -- possible support moves
  let supportMoves = [ SupportMove unitPos otherUnit (provNodeToProv node1)
                     | node1 <- adjacentNodes
                     , (otherUnit, node2) <- movedTo
                     , node1 == node2 ]
  
  friendlyUnits <- getMyUnits  

  -- adjacent units
  let adjUnits = [ (otherUnit, otherPos) 
		 | (otherUnit, otherPos) <- friendlyUnits
		 , targNode <- adjacentNodes
		 , targNode == otherPos ] 

  -- own units that are holding
  let holdOrders = mapMaybe (\ho -> case ho of 
			      Hold u -> Just u
			      _ -> Nothing) currOrders

  -- possible support holds
  let supportHolds = [ SupportHold unitPos otherUnit
		     | (otherUnit, _) <- adjUnits
		     , holdUnit <- holdOrders
                     , holdUnit == otherUnit ]
    
  -- possible simple moves
  let moveMoves = map (Move unitPos) adjacentNodes

  -- hold move
  let holdMoves = [Hold unitPos]

  -- TODO: create convoy moves here and add them to allMoves below
  -- let convoyMoves = ...
  
  -- choose a move randomly and append it to the rest
  let allMoves = supportMoves ++ supportHolds ++ moveMoves ++ holdMoves
  order <- randElem allMoves
  return $ order : currOrders
  -}
--------------------------------------------------------
--                Metrics motherfucka                 --
--------------------------------------------------------

-- given a power returns the number of supply centers owned and non-supply centers owned
-- ermm non-scs are not owned??
-- getProvOcc :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => Power -> m (Int, Int)
-- getProvOcc power = do
--   suppC <- getSupplies power
--   units <- getUnits power
--   let occupied_prov = map (provNodeToProv . unitPositionLoc) units
--   return (length suppC, length (occupied_prov `div` suppC)) 


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

