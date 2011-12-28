module Diplomacy.AI.Bots.DumbBot.Scoring ( calculateDestValue 
                                         , calculateWinterDestValue 
                                         , calculateComp ) where

import Diplomacy.Common.Data
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Common

import Control.Monad
import Control.Applicative

import Data.Maybe
import Data.List

import qualified Data.Map as Map

_ProximityDepth = 10

-- WEIGHTS
_SpringAttackWeight = 700
_SpringDefenceWeight = 300

_FallAttackWeight = 700
_FallDefenceWeight = 300

_SpringProximityWeights = [ 100
                          , 1000
                          , 30
                          , 10
                          , 6
                          , 5
                          , 4
                          , 3
                          , 2
                          , 1 ]

_SpringStrengthWeight = 1000
_SpringCompetititonWeight = 1000

_FallProximityWeights = [ 1000
                        , 100
                        , 30
                        , 10
                        , 6
                        , 5
                        , 4
                        , 3
                        , 2
                        , 1 ]

_FallStrengthWeight = 1000
_FallCompetititonWeight = 1000

_BuildDefenceWeight = 1000

_BuildProximityWeights = [ 1000
                         , 100
                         , 30
                         , 10
                         , 6
                         , 5
                         , 4
                         , 3
                         , 2
                         , 1 ]

_DefenceDefenceWeight = 1000

_DefenceProximityWeights = [ 1000
                           , 100
                           , 30
                           , 10
                           , 6
                           , 5
                           , 4
                           , 3
                           , 2
                           , 1 ]

_PlayAlternative = 50

_AlternativeDifferenceModifier = 500

powerSizeMap :: (Functor m, OrderClass o, MonadBrain o m) => m (Map.Map Power Int)
powerSizeMap = Map.map length . noUno . supplyOwnerships <$> asksGameState gameStateMap

powerSize :: (Functor m, OrderClass o, MonadBrain o m) => Power -> m Int
powerSize pow = (Map.! pow) <$> powerSizeMap

calculateDefenceValue :: ( Functor m, OrderClass o
                         , MonadBrain o m
                         , MonadGameKnowledge h m ) => Province -> m Int
calculateDefenceValue prov = do
  adjUnits <- getAdjacentUnits prov
  maximum <$> mapM (powerSize . unitPositionP) adjUnits

calculateProxs :: ( Functor m, Monad m, OrderClass o, MonadBrain o m
                  , MonadGameKnowledge h m ) => m [Map.Map ProvinceNode Int]
calculateProxs = do
  allProvs <- getAllProvs
  p2pn <- mapDefProvNodes <$> asksGameInfo gameInfoMapDef
  let allProvNodes = concatMap (p2pn Map.!) allProvs
  mySupplies <- getMySupplies
  supplyPowerMap <- getSupplyPowerMapNoUno

  (attackWeight, defenceWeight) <- getAtkDefWeights

  -- starting values
  let provVal pr = if provinceIsSupply pr
                   then if pr `elem` mySupplies
                        then (defenceWeight *) <$> calculateDefenceValue pr
                        else (attackWeight *) <$> 
                             (maybe (return 0) powerSize (pr `Map.lookup` supplyPowerMap))
                   else return 0
  startVals <- zip allProvs <$> mapM provVal allProvs

  -- proximity 0
  let prox0 = Map.fromList $ concatMap (\(p, v) -> zip (p2pn Map.! p) (repeat v)) startVals
  
  let iterateM f = sequence . iterate (>>= f)

  let provProx prevMap newMap provNode = do
        nodes <- (provNode :) <$> getAllAdjacentNodes2 provNode
        let val = sum (map (prevMap Map.!) nodes) `div` 5 
        return $ Map.insert provNode val newMap
  let nextProx prevMap = foldM (provProx prevMap) Map.empty allProvNodes
  proxs <- iterateM nextProx (return prox0)
  
  return (take _ProximityDepth proxs)

-- strength, competition
calculateProvPowStr :: ( Functor m, Monad m, OrderClass o, MonadBrain o m
                       , MonadGameKnowledge h m ) => m (Map.Map Province (Int, Power))
calculateProvPowStr = do
  let oneProv prov = do
        adjUnits <- getAdjacentUnits prov
        let grp = groupBy (\u1 u2 -> unitPositionP u1 == unitPositionP u2) adjUnits
        let powStrs = map (\us@(u : _) -> (length us, unitPositionP u)) grp
        return (maximum ((0, Neutral) : powStrs))
  allProvs <- getAllProvs
  Map.fromList <$> mapM (\p -> (,) p <$> oneProv p) allProvs

calculateComp :: ( Functor m, Monad m, OrderClass o, MonadBrain o m
                 , MonadGameKnowledge h m ) => m (Map.Map Province Int)
calculateComp = do
  provPowStr <- calculateProvPowStr
  myPower <- getMyPower
  return (Map.map (\(i, p) -> if p == myPower then 0 else i) provPowStr)

calculateAddedProxs :: ( Functor m, Monad m, OrderClass o, MonadBrain o m
                       , MonadGameKnowledge h m ) => m (Map.Map ProvinceNode Int)
calculateAddedProxs = do
  proxs <- calculateProxs
  allProvNodes <- getAllProvNodes
  proxWeights <- getProxWeights
  
  let addedProxs = Map.fromList $ map
                   (\provNode ->
                     (,) provNode $
                     foldl (\destWeight (proxWeight, proxMap) ->
                             destWeight + (proxMap Map.! provNode) * proxWeight) 0
                     (zip proxWeights proxs)) allProvNodes
  return addedProxs

calculateDestValue :: ( Functor m, Monad m, OrderClass o, MonadBrain o m
                      , MonadGameKnowledge h m ) => m (Map.Map ProvinceNode Int)
calculateDestValue = do
  addedProxs <- calculateAddedProxs
  
  (strWeight, compWeight) <- getStrCompWeights
  provPowStr <- calculateProvPowStr
  myPower <- getMyPower
  let destMap = Map.mapWithKey (\provNode dest ->
                                 let prov = provNodeToProv provNode in
                                 let (str, pow) = provPowStr Map.! prov in
                                 if pow == myPower
                                 then dest + str * strWeight
                                 else dest - str * compWeight
                               ) addedProxs
  return destMap

calculateWinterDestValue :: ( Functor m, Monad m, OrderClass o, MonadBrain o m
                            , MonadGameKnowledge h m ) => m (Map.Map ProvinceNode Int)
calculateWinterDestValue = do
  addedProxs <- calculateAddedProxs
  (_, defenceWeight) <- getAtkDefWeights
  
  return . Map.fromList =<< mapM
    (\(pn, dest) -> (,) pn <$> do
        def <- calculateDefenceValue (provNodeToProv pn)
        return (dest + defenceWeight * def)
    ) (Map.toList addedProxs)

getAtkDefWeights :: (Functor m, OrderClass o, MonadBrain o m) => m (Int, Int)
getAtkDefWeights = do
  phase <- turnPhase <$> asksGameState gameStateTurn
  return $ if phase `elem` [Fall, Autumn]
           then (_FallAttackWeight, _FallDefenceWeight)
           else (_SpringAttackWeight, _SpringDefenceWeight)

getStrCompWeights :: (Functor m, OrderClass o, MonadBrain o m) => m (Int, Int)
getStrCompWeights = do
  phase <- turnPhase <$> asksGameState gameStateTurn
  return $ if phase `elem` [Fall, Autumn]
           then (_FallStrengthWeight, _FallCompetititonWeight)
           else (_SpringStrengthWeight, _SpringCompetititonWeight)

getProxWeights :: (Functor m, OrderClass o, MonadBrain o m) => m [Int]
getProxWeights = do
  phase <- turnPhase <$> asksGameState gameStateTurn
  return $ if phase `elem` [Fall, Autumn]
           then _FallProximityWeights
           else _SpringProximityWeights