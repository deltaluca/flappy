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
                                  , getProvNodeUnitMap
                                  , getProvUnitMap
                                  , getAdjacentNodes
                                  , getAdjacentUnits
                                  , getAdjacentUnits2
                                  , getAllAdjacentNodes
                                  , getAllAdjacentNodes2
                                  , getSupplyPowerMap
                                  , getSupplyPowerMapNoUno
                                  , getAllProvs
                                  , getAllProvNodes
                                  , randElem
				  , randElems
                                  , getCurTurn
                                  , provNodeToProv
                                  , noUno
                                  , genLegalOrders
                                  , getOMTargetUnit
                                  , getOMSubjectUnit
                                  -- Metrics
                                  , getProvOcc
                                  , getSuppControl
                                  , getAdjProvOcc
				  -- Other non-metric stuff
                                  , lengthI
                                  , brainLog
                                  , shuff
                                  ) where

import Diplomacy.AI.SkelBot.CommonCache
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.Common.Data

import System.Random.Shuffle
import System.Log.Logger
import Data.Maybe
import Data.List
import Data.Time.Clock
import Control.Applicative
import Control.Monad
import Control.Monad.Random
import Control.Monad.IO.Class

import qualified Data.Map as Map

-- |for hslogger bug
import Control.Exception
import Control.DeepSeq

-- |get own power token
getMyPower :: (MonadGameKnowledge h m) => m Power
getMyPower = asksGameInfo gameInfoPower

-- |get supplies for a given power
getSupplies :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => Power -> m [Province]
getSupplies power = do
  curMapState <- asksGameState gameStateMap
  let supplies = supplyOwnerships curMapState
  return $ maybe [] id (Map.lookup power supplies)

-- |get own supplies
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

-- |get units for a given power (special cases depending on regular phase or retreat phase)
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

-- |get own units
getMyUnits :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m [UnitPosition]
getMyUnits = getUnits =<< getMyPower

-- |get possible retreats
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

-- |get adjacent nodes to a given unit
getAdjacentNodes :: (MonadGameKnowledge h m) => UnitPosition -> m [ProvinceNode]
getAdjacentNodes (UnitPosition _ unitType provNode) = do
  mapDef <- asksGameInfo gameInfoMapDef
  let adjMap = mapDefAdjacencies mapDef
  return $ adjMap ! (provNode, unitType)

-- |gets all adjacent nodes to a given province
getAllAdjacentNodes :: (MonadGameKnowledge h m, MonadBrainCache m) =>
                       Province -> m [ProvinceNode]
getAllAdjacentNodes prov = return . (Map.! prov)
                           =<< asksCache brainCacheAllAdjacentNodes

-- |gets all adjacent nodes to a given provinceNode
getAllAdjacentNodes2 :: (MonadGameKnowledge h m, MonadBrainCache m) =>
                        ProvinceNode -> m [ProvinceNode]
getAllAdjacentNodes2 provNode = return . (Map.! provNode)
                                =<< asksCache brainCacheAllAdjacentNodes2

-- |pick a random element from a list
randElem :: (MonadRandom m) => [a] -> m a
randElem l = do
  let len = length l
  if len == 0
    then error "randElem called with empty list"
    else return . (l !!) =<< getRandomR (0, len - 1)

-- |pick N random elements from a list
randElems :: (MonadRandom m) => Int -> [a] -> m [a]
randElems n l = return . take n =<< shuff l

getSupplyPowerMap :: (OrderClass o, MonadBrain o m,
                      MonadGameKnowledge h m) => m (Map.Map Province Power)
getSupplyPowerMap = do
  curMapState <- asksGameState gameStateMap
  let supplies = supplyOwnerships curMapState
  return . Map.fromList .
    concatMap (\(p, ps) -> zip ps (repeat p)) . Map.toList $ supplies

getSupplyPowerMapNoUno :: (OrderClass o, MonadBrain o m,
                           MonadGameKnowledge h m) => m (Map.Map Province Power)
getSupplyPowerMapNoUno = do
  curMapState <- asksGameState gameStateMap
  let supplies = noUno (supplyOwnerships curMapState)
  return . Map.foldlWithKey
    (\mp pow prs -> foldl (\m pr -> Map.insert pr pow m) mp prs) Map.empty $ supplies

getAdjacentUnits :: (MonadGameKnowledge h m, MonadBrainCache m) =>
                    Province -> m [UnitPosition]
getAdjacentUnits prov = do
  pnUnitMap <- getProvNodeUnitMap
  adjNodes <- getAllAdjacentNodes prov
  return $ mapMaybe (`Map.lookup` pnUnitMap) adjNodes

getProvNodeUnitMap :: (MonadBrainCache m) => m (Map.Map ProvinceNode UnitPosition)
getProvNodeUnitMap = asksCache brainCacheProvNodeUnitMap

getProvUnitMap :: (MonadBrainCache m) => m (Map.Map Province UnitPosition)
getProvUnitMap = asksCache brainCacheProvUnitMap

getCurTurn :: (MonadBrainCache m) => m Int
getCurTurn = asksCache brainCacheCurTurn

-- |same as getAdjacentUnits but only gives units that can move to the province
getAdjacentUnits2 :: (MonadGameKnowledge h m, MonadBrainCache m) =>
                     Province -> m [UnitPosition]
getAdjacentUnits2 prov = do
  filterM (\u -> return . elem prov . map provNodeToProv =<< getAdjacentNodes u)
    =<< getAdjacentUnits prov

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

getOMTargetUnit :: OrderMovement -> UnitPosition
getOMTargetUnit order = 
  case order of 
    Hold u            -> u
    Move u _          -> u
    SupportHold _ u   -> u
    SupportMove _ u _ -> u
    Convoy _ u _      -> u
    MoveConvoy u _ _  -> u

getOMSubjectUnit :: OrderMovement -> UnitPosition
getOMSubjectUnit order = 
  case order of 
    Hold u            -> u
    Move u _          -> u
    SupportHold u _   -> u
    SupportMove u _ _ -> u
    Convoy u _ _      -> u
    MoveConvoy u _ _  -> u

-- |Generates all legal orders only involving own units
genLegalOrders :: (OrderClass o, MonadBrain o m,
                   MonadGameKnowledge h m, MonadBrainCache m) =>
                  (Map.Map UnitPosition [OrderMovement]) ->
                  UnitPosition -> m (Map.Map UnitPosition [OrderMovement])
genLegalOrders currOrders unitPos = do
  adjacentNodes <- getAdjacentNodes unitPos
  pUnitMap <- getProvUnitMap
  myPower <- getMyPower
  friendlies <- return.(filter (/= unitPos)) =<< getMyUnits
   
  adjUnitNodes <- mapM getAdjacentNodes friendlies
  
  let relevantAdjUnitNodes = (map (intersect adjacentNodes) adjUnitNodes)
  
  let supportMoves = concat [map ((SupportMove unitPos otherUnit).provNodeToProv) otherNodes | (otherUnit, otherNodes) <- zip friendlies relevantAdjUnitNodes]

  let adjUnits =  [ otherUnit
        	        | otherPos <- adjacentNodes
                  , otherUnit <- maybeToList $
                    provNodeToProv otherPos `Map.lookup` pUnitMap
        	        , unitPositionP otherUnit == myPower ] 

  -- |possible support holds (ie. just adjacent friendlies)
  let supportHolds =  [ SupportHold unitPos otherUnit
        	            | otherUnit <- adjUnits]

  -- |possible simple moves
  let moveMoves = map (Move unitPos) adjacentNodes

  -- |hold move
  let holdMoves = [Hold unitPos]

  -- |TODO: create convoy moves here and add them to allMoves below
  -- |let convoyMoves = ...
  
  -- |add all possible moves for this unit into the map
  let allMoves = supportMoves ++ moveMoves ++ holdMoves ++ supportHolds
  return $ Map.insert unitPos allMoves currOrders

--------------------------------------------------------
--                Metrics                             --
--------------------------------------------------------


lengthI = fromIntegral . length

-- |given a power returns the number of supply centers owned and non-supply centers occupied
getProvOcc :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => Power -> m (Integer, Integer)
getProvOcc power = do
   suppC <- getSupplies power
   units <- getUnits power
   let occupied_prov = map (provNodeToProv . unitPositionLoc) units
   return (lengthI suppC, lengthI (occupied_prov \\ suppC)) 


-- |returns a three-tuple of supply center control, (you, enemy, no-one)
getSuppControl :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m (Integer, Integer, Integer)
getSuppControl = do
  mapDef <- asksGameInfo gameInfoMapDef

  let provinces = mapDefProvinces mapDef
  let numSupplies = lengthI . filter provinceIsSupply $ provinces
  
  powerSupplies <- mapM getSupplies (mapDefPowers mapDef)
  let allSupplies = sum $ map lengthI powerSupplies
  mySupplies <- return . lengthI =<< getMySupplies
  
  return (mySupplies, allSupplies - mySupplies, numSupplies - mySupplies - allSupplies)


-- |returns a three-tuple of province occupation around adjacent provinces only
getAdjProvOcc :: (OrderClass o, MonadBrain o m,
                  MonadGameKnowledge h m, MonadBrainCache m) =>
                 UnitPosition -> m (Integer, Integer, Integer)
getAdjProvOcc unit = do
  provNodes <- getAdjacentNodes unit
  let provs = map provNodeToProv provNodes
  unitPoss <- (getAdjacentUnits.provNodeToProv.unitPositionLoc) unit
  myPower <- getMyPower
  let ourOcc = lengthI . filter ((myPower ==) . unitPositionP) $ unitPoss
  let enemyOcc = lengthI unitPoss - ourOcc
  let noOcc = lengthI provs - lengthI unitPoss
  return (noOcc, ourOcc, enemyOcc) 
	

shuff :: (MonadRandom m) => [a] -> m [a]
shuff [] = return []
shuff l = shuffleM l

brainLog :: (MonadIO m, OrderClass o, MonadBrain o m) => String -> m ()
brainLog msg = do
  toPrint <- liftIO . evaluate . force $ msg
  time <- liftIO getCurrentTime
  Turn phase year <- asksGameState gameStateTurn
  liftIO . noticeM "Main" $
    "[" ++ show time ++ " : " ++ show year ++
    " (" ++ show phase ++ ")] " ++ toPrint  
