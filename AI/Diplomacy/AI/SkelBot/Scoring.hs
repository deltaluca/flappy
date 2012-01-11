module Diplomacy.AI.SkelBot.Scoring ( calculateDestValue
                                    , calculateWinterDestValue
                                    , calculateComp ) where

import Diplomacy.Common.Data
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Common
import Diplomacy.AI.SkelBot.CommonCache

import Control.Monad
--import Control.Monad.IO.Class
import Control.Applicative

import Data.Tuple
import Data.Maybe
import Data.List

--import Control.DeepSeq

import qualified Data.Map as Map

--import Debug.Trace


_ProximityDepth = 10

-- WEIGHTS
_SpringAttackWeight = 700
_SpringDefenceWeight = 300

_FallAttackWeight = 600
_FallDefenceWeight = 400

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

_RemoveDefenceWeight = 1000

_RemoveProximityWeights = [ 1000
                          , 100
                          , 30
                          , 10
                          , 6
                          , 5
                          , 4
                          , 3
                          , 2
                          , 1 ]

-- CHECK where to use
_PlayAlternative = 50 :: Integer

-- CHECK where to use
_AlternativeDifferenceModifier = 500 :: Integer

_SizeSquareCoefficient = 1
_SizeCoefficient = 4
_SizeConstant = 16

powerSizeMap :: (Functor m, OrderClass o, MonadBrain o m) => m (Map.Map Power Integer)
powerSizeMap = Map.map (squarePower . lengthI) {-. noUno-} . supplyOwnerships <$>
               asksGameState gameStateMap

squarePower :: Integer -> Integer
squarePower x = _SizeSquareCoefficient * x * x +
                _SizeCoefficient       * x +
                _SizeConstant

powerSize :: (Functor m, OrderClass o, MonadBrain o m) => Power -> m Integer
powerSize pow = fromMaybe 0 <$> (Map.lookup pow) <$> powerSizeMap

calculateDefenceValue :: ( Functor m, Monad m, OrderClass o
                         , MonadBrain o m
                         , MonadGameKnowledge h m
                         , MonadBrainCache m ) => Province -> m Integer
calculateDefenceValue prov = do
  --brainLog "Entering calculateDefenceValue"
  myPower <- getMyPower
  adjUnits <- getAdjacentUnits2 prov
  --brainLog $ "adjUnits: " ++ show adjUnits
  maximum . (0 :) <$> mapM
    ((\p -> if p == myPower then return 0 else powerSize p) . unitPositionP) adjUnits

calculateProxs :: ( Functor m, Monad m, OrderClass o, MonadBrain o m
                  , MonadGameKnowledge h m, MonadBrainCache m) =>
                  m [Map.Map ProvinceNode Integer]
calculateProxs = do
  allProvs <- getAllProvs
  p2pn <- mapDefProvNodes <$> asksGameInfo gameInfoMapDef
  let allProvNodes = concat (Map.elems p2pn)
  myPower <- getMyPower
  supplyPowerMap <- getSupplyPowerMap

  (attackWeight, defenceWeight) <- getAtkDefWeights

  -- starting values
  let provVal pr = if provinceIsSupply pr
                   then
                     let owner = pr `Map.lookup` supplyPowerMap in
                     if owner  == Just myPower
                     then (defenceWeight *) <$> calculateDefenceValue pr
                     else (attackWeight *) <$>
                             (maybe (return 0) powerSize owner)
                   else return 0
  startVals <- zip allProvs <$> mapM provVal allProvs


  -- proximity 0
  let prox0 = Map.fromList $ concatMap (\(p, v) -> zip (p2pn Map.! p) (repeat v)) startVals


  let iterateM f = sequence . take _ProximityDepth . iterate (>>= f)

  let provProx prevMap newMap provNode = do
        nodes <- (provNode :) <$> getAllAdjacentNodes2 provNode
        let val = sum (map (prevMap Map.!) nodes) `div` 5
        return $ Map.insert provNode val newMap
  let nextProx prevMap = foldM (provProx prevMap) Map.empty allProvNodes
  proxs <- iterateM nextProx (return prox0)

  return proxs

-- strength, competition
calculateProvPowStr :: ( Functor m, Monad m, OrderClass o, MonadBrain o m
                       , MonadGameKnowledge h m, MonadBrainCache m) =>
                       m (Map.Map Province (Integer, Power))
calculateProvPowStr = do
  provUnitMap <- getProvUnitMap
  let oneProv prov = do
        adjUnits <- getAdjacentUnits prov
        let allUnits = maybeToList (prov `Map.lookup` provUnitMap) ++ adjUnits
            unitNums = (\f -> foldl f (Map.singleton Neutral 0) allUnits) $
                       (\m u -> Map.alter (Just . maybe 1 succ) (unitPositionP u) m)
        return . maximum . map swap $ (Map.toList unitNums)
        
  allProvs <- getAllProvs
  Map.fromList <$> mapM (\p -> (,) p <$> oneProv p) allProvs

calculateComp :: ( Functor m, Monad m, OrderClass o, MonadBrain o m
                 , MonadGameKnowledge h m, MonadBrainCache m) =>
                 m (Map.Map Province Integer)
calculateComp = do
  provPowStr <- calculateProvPowStr
  myPower <- getMyPower
  return (Map.map (\(i, p) -> if p == myPower then 0 else i) provPowStr)

calculateAddedProxs :: ( Functor m, Monad m, OrderClass o, MonadBrain o m
                       , MonadGameKnowledge h m, MonadBrainCache m) =>
                       m (Map.Map ProvinceNode Integer)
calculateAddedProxs = do
  --brainLog "Entering calculateAddedProxs"
  proxs <- calculateProxs
  --brainLog $ "proxs: " ++ show proxs
  allProvNodes <- getAllProvNodes
  --brainLog $ "allProvNodes: " ++ show allProvNodes
  proxWeights <- getProxWeights
  --brainLog $ "proxWeights: " ++ show proxWeights
  

  let addedProxs = Map.fromList $ map
                   (\provNode ->
                     (,) provNode $
                     foldl (\destWeight (proxWeight, proxMap) ->
                             destWeight + (proxMap Map.! provNode) * proxWeight) 0
                     (zip proxWeights proxs)) allProvNodes
  return addedProxs

calculateDestValue :: ( Functor m, Monad m, OrderClass o, MonadBrain o m
                      , MonadGameKnowledge h m, MonadBrainCache m) =>
                      m (Map.Map ProvinceNode Integer)
calculateDestValue = do
  --brainLog "Entering calculateDestValue"
  addedProxs <- calculateAddedProxs
  --brainLog $ "addedProxs: " ++ show addedProxs
  (strWeight, compWeight) <- getStrCompWeights
  --brainLog $ "(strWeight, compWeight): " ++ show (strWeight, compWeight)
  provPowStr <- calculateProvPowStr
  --brainLog $ "provPowStr: " ++ show provPowStr
  myPower <- getMyPower
  --brainLog $ "myPower: " ++ show myPower  
  
  let destMap = Map.mapWithKey (\provNode dest ->
                                 let prov = provNodeToProv provNode in
                                 let (str, pow) = provPowStr Map.! prov in
                                 if pow == myPower
                                 then dest + str * strWeight
                                 else dest - str * compWeight
                               ) addedProxs
  return destMap

calculateWinterDestValue :: ( Functor m, Monad m, OrderClass o, MonadBrain o m
                            , MonadGameKnowledge h m, MonadBrainCache m) =>
                            m (Map.Map ProvinceNode Integer)
calculateWinterDestValue = do
  --brainLog $ "Entering calculateWinterDestValue"
  addedProxs <- calculateAddedProxs
  --brainLog $ "addedProxs: " ++ show addedProxs
  defenceWeight <- getBldRemDefence
  --brainLog $ "defenceWeight: " ++ show defenceWeight

  return . Map.fromList =<< mapM
    (\(pn, dest) -> (,) pn <$> do
        def <- calculateDefenceValue (provNodeToProv pn)
        return (dest + defenceWeight * def)
    ) (Map.toList addedProxs)

getAtkDefWeights :: (Functor m, OrderClass o, MonadBrain o m) => m (Integer, Integer)
getAtkDefWeights = do
  phase <- turnPhase <$> asksGameState gameStateTurn
  return $ if phase `elem` [Fall, Autumn]
           then (_FallAttackWeight, _FallDefenceWeight)
           else (_SpringAttackWeight, _SpringDefenceWeight)

getStrCompWeights :: (Functor m, OrderClass o, MonadBrain o m) => m (Integer, Integer)
getStrCompWeights = do
  phase <- turnPhase <$> asksGameState gameStateTurn
  return $ if phase `elem` [Fall, Autumn]
           then (_FallStrengthWeight, _FallCompetititonWeight)
           else (_SpringStrengthWeight, _SpringCompetititonWeight)

getProxWeights :: (MonadGameKnowledge h m,
                   Functor m, OrderClass o, MonadBrain o m) => m [Integer]
getProxWeights = do
  phase <- turnPhase <$> asksGameState gameStateTurn
  if phase `elem` [Fall, Autumn]
    then return _FallProximityWeights
    else if phase /= Winter
         then return _SpringProximityWeights
         else do
           difference <- (-) `liftM2`
                         (length <$> getMyUnits) $
                         (length <$> getMySupplies)
           return $ if difference < 0
                    then _BuildProximityWeights
                    else _RemoveProximityWeights

getBldRemDefence :: (MonadGameKnowledge h m,
                     Functor m, OrderClass o, MonadBrain o m) => m Integer
getBldRemDefence = do
  difference <- (-) `liftM2`
                (length <$> getMyUnits) $
                (length <$> getMySupplies)
  return $ if difference < 0
           then _BuildDefenceWeight
           else _RemoveDefenceWeight
