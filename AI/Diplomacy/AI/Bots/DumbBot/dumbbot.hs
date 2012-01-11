-- The following bot is based on David Norman's DumbBot algorithm
-- Original DumbBot: http://www.ellought.demon.co.uk/dipai/dumbbot_source.zip
-- Short explanation: http://www.daide.org.uk/wiki/DumbBot_Algorithm

-- the only functional difference between this bot and the original is
-- the sampling method used when generating moves

{-# LANGUAGE TypeSynonymInstances, FlexibleInstances, MultiParamTypeClasses #-}
module Main(main) where

import Diplomacy.AI.SkelBot.Scoring

import Diplomacy.AI.SkelBot.SkelBot
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.DipBot
import Diplomacy.AI.SkelBot.Common
import Diplomacy.AI.SkelBot.CommonCache

import Diplomacy.Common.Data

import Data.Maybe
import Data.List
import System.Random
import Control.Monad.IO.Class
import Control.Monad.Random
import Control.Monad.Trans
import Control.Monad
--import Control.DeepSeq

--import Debug.Trace

import qualified Data.Map as Map

-- pure brains

type DumbBrain o = RandT StdGen (BrainCacheT (Brain o ()))

-- type DumbBrainMove = DumbBrain OrderMovement
-- type DumbBrainRetreat = DumbBrain OrderRetreat
-- type DumbBrainBuild = DumbBrain OrderBuild

-- impure brains
type DumbBrainCommT o = BrainCommT o ()

type DumbBrainMoveCommT = BrainCommT OrderMovement ()
type DumbBrainRetreatCommT = BrainCommT OrderRetreat ()
type DumbBrainBuildCommT = BrainCommT OrderBuild ()

instance (OrderClass o) => MonadBrainCache (DumbBrain o) where
  askCache = lift askCache

_SEED = 0 :: Int

main = do
  --setStdGen (mkStdGen _SEED)
  skelBot dumbBot

dumbBot :: (Functor m, MonadIO m) => DipBot m ()
dumbBot = DipBot { dipBotName = "FlappyDumbBot"
                 , dipBotVersion = 0.1
                 , dipBotBrainMovement = dumbBrainMoveComm
                 , dipBotBrainRetreat = dumbBrainRetreatComm
                 , dipBotBrainBuild = dumbBrainBuildComm
                 , dipBotProcessResults = dumbProcessResults
                 , dipBotInitHistory = dumbInitHistory 
                 , dipBotGameOver = return ()
                 }

withStdGen :: (MonadIO m, OrderClass o) => DumbBrain o () -> DumbBrainCommT o m ()
withStdGen brain = do
  stdGen <- liftIO getStdGen
  
  (_, nextStdGen) <- liftBrain   -- lift pure brain
    . runBrain                  -- no underlying monad
    . runBrainCache
    . runRandT brain $ stdGen
  
  liftIO $ setStdGen nextStdGen  -- set new stdgen

dumbBrainMoveComm :: (Functor m, MonadIO m) => DumbBrainMoveCommT m ()
dumbBrainMoveComm = withStdGen $ do
  --brainLog "Entering dumbBrainMoveComm"
  units <- getMyUnits
  --brainLog $ "Units : " ++ show units
  runits <- shuff units
  --brainLog $ "Random Units : " ++ show runits
  destMap <- calculateDestValue
  --brainLog $ "DestMap : " ++ show destMap
  competition <- calculateComp
  --brainLog $ "Competition : " ++ show competition

  --brainLog "CALCULATING MMAP"

  mmap <- (\f -> foldM f Map.empty runits) $ \movementMap unit -> do
    --brainLog $ "Move for " ++ show unit
    adjNodes <- getAdjacentNodes unit
    let makeMove nodeset = do
          chosenNode <- chooseNode destMap nodeset
          --brainLog $ "Chosen node: " ++ show chosenNode
          let prov = provNodeToProv chosenNode
          case prov `Map.lookup` movementMap of
            Nothing ->          -- if noone's choosing it
              return $ Map.insert prov [(unit, chosenNode)] movementMap
            Just moveList ->    -- if there are peeps choosing it
              if competition Map.! prov >= lengthI moveList ||
                 unitPositionLoc unit == chosenNode -- if support is needed or holding
              then
                return $ Map.insert prov ((unit, chosenNode) : moveList) movementMap
              else
                makeMove (chosenNode `delete` nodeset) -- try again
    
    makeMove (unitPositionLoc unit : adjNodes)

  --brainLog $ show mmap

    -- make the moves
  (\f -> mapM_ f (Map.toList mmap)) $ \(prov, unitNodeList) -> do
    -- first list is possibly a singleton with the holding unit
    let (as, bs) = partition (\(u, pn) -> unitPositionLoc u == pn) unitNodeList
    case listToMaybe as of
      Nothing -> do
        let ((mvUnit, mvPn) : supps) = bs
        appendOrder $ Move mvUnit mvPn
        mapM_ (\(suppUnit, _) ->
                appendOrder $ SupportMove suppUnit mvUnit prov) supps
      Just (holdUnit, _) -> do
        appendOrder $ Hold holdUnit
        mapM_ (\(suppUnit, _) ->
                appendOrder $ SupportHold suppUnit holdUnit) bs

  --brainLog "MOVES MADE"
  -- (\f -> foldM_ f [] runits) $ \occNodeUnits unit -> do
  --   adjNodes <- getAdjacentNodes unit
  --         makeMove nodeset = do
  --           chosenNode <- chooseNode destMap nodeset
  --           case chosenNode `lookup` occNodeUnits of
  --             Nothing -> do                             -- if noone occupies
  --               appendOrder $ move unit chosenNode -- move
  --               return $ (chosenNode, unit) : occNodeUnits -- add occupation
  --             Just otherUnit ->                          -- if someone already occupies
  --               if competition Map.! (provNodeToProv chosenNode) > 1 -- if support is needed
  --               then do
  --                 appendOrder $ support unit otherUnit chosenNode -- support
  --                 return $ (unitPositionLoc unit, unit) : occNodeUnits -- add occupation
  --               else makeMove (chosenNode `delete` nodeset) -- try again
  
  --     makeMove (unitPositionLoc unit : adjNodes)

  -- DEBUG should this be in Common.hs?
-- move :: UnitPosition -> ProvinceNode -> OrderMovement
-- move unit node =
--   if unitPositionLoc unit == node
--   then Hold unit
--   else Move unit node

-- support :: UnitPosition -> UnitPosition -> ProvinceNode -> OrderMovement
-- support unit otherUnit node =
--   if unitPositionLoc otherUnit == node
--   then SupportHold unit otherUnit
--   else SupportMove unit otherUnit (provNodeToProv node)

chooseNode destMap nodes = do
  -- square the weights
  let weights = map (\x -> if x > 0 then x * x else 0) .
                normalise . map (destMap Map.!) $ nodes
      weightsSum = sum weights
  x <- getRandomR (0.0, weightsSum)
  return $ pickNode (zip weights nodes) x
  

pickNode :: [(Double, a)] -> Double -> a
pickNode [(_, n)] _ = n
pickNode ((a, n) : as) x = if x < a
                           then n
                           else pickNode as (x - a)
pickNode [] _ = error "pickNode []"

-- DEBUG refactor stuff
dumbBrainRetreatComm :: (Functor m, MonadIO m) => DumbBrainRetreatCommT m ()
dumbBrainRetreatComm = withStdGen $ do
  --brainLog $ "Entering dumbBrainRetreatComm"
  
  destMap <- calculateDestValue
  
  --brainLog $ "destMap: " ++ show destMap
  
  retreats <- lift getMyRetreats
  
  --brainLog $ "retreats: " ++ show retreats
  
  rretreats <- shuff retreats

  --brainLog $ "rretreats: " ++ show rretreats
  
  putOrders $ Just []
  (\f -> foldM_ f [] rretreats) $ \occNodeUnits (unit, retNodes) -> do
    let makMove [] = lift (appendOrder (Disband unit)) >> return occNodeUnits
        makMove nodeset = do
          chosenNode <- chooseNode destMap nodeset
          case chosenNode `lookup` occNodeUnits of
            Nothing -> do                             -- if noone occupies
              appendOrder $ Retreat unit chosenNode -- move
              return $ (chosenNode, unit) : occNodeUnits -- add occupation
            Just _ ->                          -- if someone already occupies
              makMove (chosenNode `delete` nodeset) -- try again
    makMove retNodes

normalise :: Integral a => [a] -> [Double]
normalise l = map (\x -> fromIntegral x / fromIntegral (sum l)) l

dumbBrainBuildComm :: (Functor m, MonadIO m) => DumbBrainBuildCommT m ()
dumbBrainBuildComm = withStdGen $ do
  --brainLog $ "Entering dumbBrainBuildComm"
  
  myPower <- getMyPower
  --brainLog $ "myPower: " ++ show myPower
  myUnits <- getMyUnits
  --brainLog $ "myUnits: " ++ show myUnits
  mySupplies <- getMySupplies
  --brainLog $ "mySupplies: " ++ show mySupplies
  puMap <- getProvUnitMap
  --brainLog $ "provUnitMap: " ++ show provUnitMap
  destMap <- calculateWinterDestValue
  --brainLog $ "destMap: " ++ show destMap
  
  let difference = length myUnits - length mySupplies

  if difference < 0
    then
    do
      --brainLog $ "Building"
      allHomes <- getMyHomeSupplies
      let homes = filter (`elem` mySupplies) allHomes
          unoccHomes = filter (\h -> maybe True (const False)
                                     (h `Map.lookup` puMap)) homes
          sortedHomes = map snd $
                        reverse . sort $
                        (`zip` unoccHomes) $
                        map ((destMap Map.!) . ProvNode) unoccHomes
      buildOrders <- mapM buildRandomUnit (take (-difference) sortedHomes)
      let allOrders = replicate (-(length buildOrders + difference)) (Waive myPower)
                      ++ buildOrders
      putOrders (Just allOrders)
    else
    do
      --brainLog $ "Removing"
      let unitVal = sort $ flip zip myUnits $ map ((destMap Map.!) . unitPositionLoc) myUnits
      -- we dont choose randomly
      putOrders . Just $ map (\(_, u) -> Remove u) (take difference unitVal)

dumbProcessResults :: [(Order, OrderResult)] -> () -> ()
dumbProcessResults _ = id

dumbInitHistory :: (MonadIO m) => GameInfo -> GameState -> m ()
dumbInitHistory _ _ = return ()

--buildRandomUnit :: Province -> DumbBrainBuild OrderBuild
buildRandomUnit prov = do
  provToProvNodes <- return . mapDefProvNodes =<< asksGameInfo gameInfoMapDef
  myPower <- getMyPower
  return . Build =<< case provinceType prov of
    Inland -> return $ UnitPosition myPower Army (ProvNode prov)
    Sea -> return $ UnitPosition myPower Fleet (ProvNode prov)
    Coastal -> do
      utyp <- randElem [Army, Fleet]
      return $ UnitPosition myPower utyp (ProvNode prov)
    BiCoastal -> do
      provNode <- randElem (provToProvNodes Map.! prov)
      case provNode of
        ProvNode _ -> return $ UnitPosition myPower Army provNode
        ProvCoastNode _ _ -> return $ UnitPosition myPower Fleet provNode
