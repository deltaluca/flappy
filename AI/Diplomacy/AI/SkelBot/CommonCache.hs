-- |module to help store common functionresults

{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Diplomacy.AI.SkelBot.CommonCache ( BrainCache(..)
                                        , BrainCacheT
                                        , MonadBrainCache(..)
                                        , runBrainCache
                                        , provNodeToProv
                                        , (!)
                                        ) where

import Diplomacy.Common.Data
import Diplomacy.Common.FloydWarshall
import Diplomacy.AI.SkelBot.Brain

import Control.Applicative
import Control.Monad.Reader
import Data.List

import qualified Data.Map as Map

data BrainCache = BrainCache
                  { brainCacheProvNodeUnitMap :: Map.Map ProvinceNode UnitPosition
                  , brainCacheProvUnitMap :: Map.Map Province UnitPosition
                  , brainCacheAllAdjacentNodes :: Map.Map Province [ProvinceNode]
                  , brainCacheAllAdjacentNodes2 :: Map.Map ProvinceNode [ProvinceNode]
                  , brainCacheFloydWarshallArmy :: ProvinceNode -> ProvinceNode -> Maybe Int
                  , brainCacheFloydWarshallFleet :: ProvinceNode -> ProvinceNode -> Maybe Int
                  }

newtype BrainCacheT m a = BrainCacheT { unBrainCache :: (ReaderT BrainCache m) a }
                        deriving (Applicative, Monad, MonadIO, MonadTrans, Functor)

class (Monad m) => MonadBrainCache m where
  askCache :: m BrainCache
  asksCache :: (BrainCache -> a) -> m a

  asksCache f = liftM f askCache

instance (Monad m) => MonadBrainCache (BrainCacheT m) where
  askCache = BrainCacheT ask

runBrainCache :: (OrderClass o, MonadBrain o m, MonadGameKnowledge h m, Applicative m) =>
                 BrainCacheT m a -> m a
runBrainCache bc = runReaderT (unBrainCache bc) =<< BrainCache
                   <$> getProvNodeUnitMap
                   <*> getProvUnitMap
                   <*> getAllAdjacentNodesMap
                   <*> getAllAdjacentNodes2Map
                   <*> (getFloydWarshall <*> return Army)
                   <*> (getFloydWarshall <*> return Fleet)

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
    
  return . Map.fromList $
    map (\unitPos -> (unitPositionLoc unitPos, unitPos)) units

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
  
  return . Map.fromList $
    map (\unitPos -> (provNodeToProv (unitPositionLoc unitPos), unitPos)) units

-- abstracts a province to just its name (ie. disregarding coasts etc.)
provNodeToProv :: ProvinceNode -> Province
provNodeToProv (ProvNode prov) = prov
provNodeToProv (ProvCoastNode prov _) = prov

getAllAdjacentNodesMap :: (MonadGameKnowledge h m) => m (Map.Map Province [ProvinceNode])
getAllAdjacentNodesMap = do
  provs <- asksGameInfo (mapDefProvinces . gameInfoMapDef)
  return . Map.fromList =<< mapM (\p -> return . ((,) p) =<< getAllAdjacentNodes p) provs

getAllAdjacentNodes2Map :: (MonadGameKnowledge h m) => m (Map.Map ProvinceNode [ProvinceNode])
getAllAdjacentNodes2Map = do
  provs <- asksGameInfo (mapDefProvinces . gameInfoMapDef)
  p2pn <- asksGameInfo (mapDefProvNodes . gameInfoMapDef)
  let pnodes = concatMap (p2pn Map.!) provs
  return . Map.fromList =<< mapM (\p -> return . ((,) p) =<< getAllAdjacentNodes2 p) pnodes

-- gets all adjacent nodes to a given province
getAllAdjacentNodes :: (MonadGameKnowledge h m) => Province -> m [ProvinceNode]
getAllAdjacentNodes prov = do
  mapDef <- asksGameInfo gameInfoMapDef
  let adjMap = mapDefAdjacencies mapDef
      provNodes = mapDefProvNodes mapDef ! prov
      nodeUnits = liftM2 (,) provNodes [Army, Fleet]
  return $ foldl1 union . map (adjMap !) $ nodeUnits

-- gets all adjacent nodes to a given provinceNode
getAllAdjacentNodes2 :: (MonadGameKnowledge h m) => ProvinceNode -> m [ProvinceNode]
getAllAdjacentNodes2 provNode = do
  mapDef <- asksGameInfo gameInfoMapDef
  let adjMap = mapDefAdjacencies mapDef
  return $ (adjMap ! (provNode, Army)) `union` (adjMap ! (provNode, Fleet))

(!) :: (Ord a) => Map.Map a [b] -> a -> [b]
mp ! i = maybe [] id (Map.lookup i mp)

getFloydWarshall :: (MonadGameKnowledge h m) => m (UnitType -> ProvinceNode -> ProvinceNode -> Maybe Int)
getFloydWarshall = do
  mapDef <- asksGameInfo gameInfoMapDef
  return (floydWarshall mapDef)