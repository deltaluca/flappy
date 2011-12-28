-- The following bot is based on David Norman's DumbBot algorithm
-- Original DumbBot: http://www.ellought.demon.co.uk/dipai/dumbbot_source.zip
-- Short explanation: http://www.daide.org.uk/wiki/DumbBot_Algorithm

-- the only functional difference between this bot and the original is
-- the sampling method used when generating moves

{-# LANGUAGE TypeSynonymInstances, FlexibleInstances, MultiParamTypeClasses #-}
module Main where

import Diplomacy.AI.Bots.DumbBot.Scoring

import Diplomacy.AI.SkelBot.SkelBot
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.DipBot
import Diplomacy.AI.SkelBot.Common

import Diplomacy.Common.DipMessage
import Diplomacy.Common.Data

import Data.Maybe
import Data.List
import System.Random
import System.Random.Shuffle
import Control.Monad.IO.Class
import Control.Monad.Random
import Control.Monad.Trans
import Control.Monad

import qualified Data.Map as Map

import Debug.Trace

-- pure brains

type DumbBrain o = RandT StdGen (Brain o ())

type DumbBrainMove = DumbBrain OrderMovement
type DumbBrainRetreat = DumbBrain OrderRetreat
type DumbBrainBuild = DumbBrain OrderBuild

-- impure brains
type DumbBrainCommT o = BrainCommT o ()

type DumbBrainMoveCommT = BrainCommT OrderMovement ()
type DumbBrainRetreatCommT = BrainCommT OrderRetreat ()
type DumbBrainBuildCommT = BrainCommT OrderBuild ()

instance (OrderClass o) => MonadBrain o (DumbBrain o) where
  asksGameState = lift . asksGameState
  getsOrders = lift . getsOrders
  putOrders = lift . putOrders

instance (OrderClass o) => MonadGameKnowledge () (DumbBrain o) where
  asksGameInfo = lift . asksGameInfo
  getsHistory = lift . getsHistory
  putHistory = lift . putHistory

main = skelBot dumbBot

dumbBot :: (MonadIO m) => DipBot m ()
dumbBot = DipBot { dipBotName = "FlappyDumbBot"
                 , dipBotVersion = 0.1
                 , dipBotBrainMovement = dumbBrainMoveComm
                 , dipBotBrainRetreat = dumbBrainRetreatComm
                 , dipBotBrainBuild = dumbBrainBuildComm
                 , dipBotProcessResults = dumbProcessResults
                 , dipBotInitHistory = dumbInitHistory }

withStdGen :: (MonadIO m, OrderClass o) =>
              DumbBrain o a -> BrainCommT o () m a
withStdGen ranBrain = do
  (ret, newStdGen) <- liftBrain
                      . runBrain
                      . runRandT ranBrain
                      =<< liftIO getStdGen
  liftIO $ setStdGen newStdGen  -- set new stdgen
  return ret

dumbBrainMoveComm :: (MonadIO m) => DumbBrainMoveCommT m ()
dumbBrainMoveComm = withStdGen $ do
  destMap <- calculateDestValue
  competition <- calculateComp
  units <- getMyUnits
  runits <- shuffleM units (length units)
    
  -- ERROR there is a bug somewhere here (inf loop)
  -- -may- have been better to split this up into helpers... NOT
  (\f -> foldM_ f [] runits) $ \occNodeUnits unit -> do
    adjNodes <- getAdjacentNodes unit
    let makeMove nodeset = do
          let nodes = unitPositionLoc unit : nodeset
              -- square the weights
              weights = map ((\x -> x * x) . (destMap Map.!)) nodes
              weightsSum = sum weights
          x <- getRandomR (0, weightsSum - 1) -- implicit normalisation
          let pickNode [(_, n)] _ = n
              pickNode ((a, n) : as) x = if x < a
                                         then n
                                         else pickNode as (x - a)
              chosenNode = pickNode (zip weights nodes) x
          case chosenNode `lookup` occNodeUnits of
            Nothing -> do                             -- if noone occupies
              appendOrder $ move unit chosenNode -- move
              return $ (chosenNode, unit) : occNodeUnits -- add occupation
            Just otherUnit ->                          -- if someone already occupies
              if competition Map.! (provNodeToProv chosenNode) > 1 -- if support is needed
              then do
                appendOrder $ support unit otherUnit chosenNode -- support
                return $ (unitPositionLoc unit, unit) : occNodeUnits -- add occupation
              else makeMove (chosenNode `delete` nodeset) -- try again
    makeMove adjNodes
                    
  -- DEBUG should this be in Common.hs?
  where move unit node =
          if unitPositionLoc unit == node
          then Hold unit
          else Move unit node
        support unit otherUnit node =
          if unitPositionLoc otherUnit == node
          then SupportHold unit otherUnit
          else SupportMove unit otherUnit (provNodeToProv node)

dumbBrainRetreatComm :: (MonadIO m) => DumbBrainRetreatCommT m ()
dumbBrainRetreatComm = withStdGen $ do
  destMap <- calculateDestValue
  retreats <- lift getMyRetreats
  rretreats <- shuffleM retreats (length retreats)
    
  (\f -> foldM_ f [] rretreats) $ \occNodeUnits (unit, retNodes) -> do
    let makeMove [] = lift (appendOrder (Disband unit)) >> return occNodeUnits
        makeMove nodeset = do
          let nodes = unitPositionLoc unit : nodeset
              -- square the weights
              weights = map ((\x -> x * x) . (destMap Map.!)) nodes
              weightsSum = sum weights
          x <- getRandomR (0, weightsSum - 1) -- implicit normalisation
          let pickNode [(_, n)] _ = n
              pickNode ((a, n) : as) x = if x < a
                                         then n
                                         else pickNode as (x - a)
              chosenNode = pickNode (zip weights nodes) x
          case chosenNode `lookup` occNodeUnits of
            Nothing -> do                             -- if noone occupies
              appendOrder $ Retreat unit chosenNode -- move
              return $ (chosenNode, unit) : occNodeUnits -- add occupation
            Just otherUnit ->                          -- if someone already occupies
              makeMove (chosenNode `delete` nodeset) -- try again
    makeMove retNodes
    

dumbBrainBuildComm :: (MonadIO m) => DumbBrainBuildCommT m ()
dumbBrainBuildComm = withStdGen $ do
  myPower <- getMyPower
  myUnits <- getMyUnits
  mySupplies <- getMySupplies
  provUnitMap <- getProvUnitMap
  destMap <- calculateWinterDestValue
    
  let difference = length myUnits - length mySupplies

  if difference < 0
    then 
    do
      homes <- getMyHomeSupplies
      let homeVal = reverse . sort $ flip zip homes $ map ((destMap Map.!) . ProvNode) homes
      putOrders . Just =<< mapM (\(_, h) -> case h `Map.lookup` provUnitMap of
                                    Nothing -> buildRandomUnit h
                                    Just _ -> return (Waive myPower)
                                ) (take (-difference) homeVal)
    else
    do
      let unitVal = sort $ flip zip myUnits $ map ((destMap Map.!) . unitPositionLoc) myUnits
      -- we dont choose randomly
      putOrders . Just $ map (\(_, u) -> Remove u) (take difference unitVal)
    
dumbProcessResults :: [(Order, OrderResult)] -> () -> ()
dumbProcessResults _ = id

dumbInitHistory :: (MonadIO m) => m ()
dumbInitHistory = return ()

buildRandomUnit :: Province -> DumbBrainBuild OrderBuild
buildRandomUnit prov = do
  provToProvNodes <- return . mapDefProvNodes =<< asksGameInfo gameInfoMapDef
  myPower <- getMyPower
  return . Build =<< case provinceType prov of
    Inland -> return $ UnitPosition myPower Army (ProvNode prov)
    Sea -> return $ UnitPosition myPower Fleet (ProvNode prov)
    Coastal -> do
      utyp <- randElem [Army, Fleet]
      return $ UnitPosition myPower Fleet (ProvNode prov)
    BiCoastal -> do
      provNode <- randElem (provToProvNodes Map.! prov)
      case provNode of
        ProvNode _ -> return $ UnitPosition myPower Army provNode
        ProvCoastNode _ _ -> return $ UnitPosition myPower Fleet provNode
