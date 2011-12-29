{- |
-------------------------- LEARNBOT ------------------------------

-}

{-# LANGUAGE TypeSynonymInstances, FlexibleInstances, MultiParamTypeClasses #-}

module Main where

import Diplomacy.AI.Bots.LearnBot.PatternWeights

import Diplomacy.AI.SkelBot.SkelBot
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.DipBot
import Diplomacy.AI.SkelBot.Common

import Diplomacy.Common.DipMessage
import Diplomacy.Common.Data

import Data.Maybe
import Data.List

import System.Random
import Control.Monad.IO.Class
import Control.Monad.Random
import Control.Monad.Trans
import Control.Monad

import qualified Data.Map as Map
import qualified Data.Traversable as Traversable

import Debug.Trace

-- pure brains
type LearnBrain o = RandT StdGen (Brain o ())

type LearnBrainMove = LearnBrain OrderMovement
type LearnBrainRetreat = LearnBrain OrderRetreat
type LearnBrainBuild = LearnBrain OrderBuild

-- impure brains
type LearnBrainCommT o = BrainCommT o ()

type LearnBrainMoveCommT = BrainCommT OrderMovement ()
type LearnBrainRetreatCommT = BrainCommT OrderRetreat ()
type LearnBrainBuildCommT = BrainCommT OrderBuild ()


instance (OrderClass o) => MonadBrain o (LearnBrain o) where
  asksGameState = lift . asksGameState
  getsOrders = lift . getsOrders
  putOrders = lift . putOrders

instance (OrderClass o) => MonadGameKnowledge () (LearnBrain o) where
  asksGameInfo = lift . asksGameInfo
  getsHistory = lift . getsHistory
  putHistory = lift . putHistory
  
main = skelBot learnBot

learnBot :: (MonadIO m) => DipBot m ()
learnBot = DipBot { dipBotName = "FlappyLearningBot"
                   , dipBotVersion = 0.1
                   , dipBotBrainMovement = learnBrainMoveComm
                   , dipBotBrainRetreat = learnBrainRetreatComm
                   , dipBotBrainBuild = learnBrainBuildComm
                   , dipBotProcessResults = learnProcessResults
                   , dipBotInitHistory = learnInitHistory }


learnBrainComm :: (MonadIO m, OrderClass o) => LearnBrain o () -> LearnBrainCommT o m ()
learnBrainComm pureBrain = do
  stdGen <- liftIO getStdGen
  
  (_, newStdGen) <- liftBrain   -- lift pure brain
    . runBrain                  -- no underlying monad
    . runRandT pureBrain $ stdGen
  
  liftIO $ setStdGen newStdGen  -- set new stdgen

learnBrainMoveComm :: (MonadIO m) => LearnBrainMoveCommT m ()
learnBrainMoveComm = learnBrainComm learnBrainMove

learnBrainRetreatComm :: (MonadIO m) => LearnBrainRetreatCommT m ()
learnBrainRetreatComm = learnBrainComm learnBrainRetreat

learnBrainBuildComm :: (MonadIO m) => LearnBrainBuildCommT m ()
learnBrainBuildComm = learnBrainComm learnBrainBuild

learnProcessResults :: [(Order, OrderResult)] -> () -> ()
learnProcessResults _ = id

learnInitHistory :: (MonadIO m) => m ()
learnInitHistory = return ()

learnBrainMove :: LearnBrainMove ()
learnBrainMove = do
  myUnits <- getMyUnits
	
  --obtain all legal moves
  legalUnitMoves <- foldM genLegalOrders Map.empty myUnits
	
  trimmedOrders <- mapM ((randElems 3) . (legalUnitMoves Map.!)) myUnits
  let possibleOrderSets = Traversable.sequenceA trimmedOrders

  
  putOrders $ Just []

learnBrainRetreat :: LearnBrainRetreat ()
learnBrainRetreat = do
  myRetreats <- getMyRetreats
  retreatOrders <- flip mapM myRetreats
            $ \(unitPos, retreatNodes) -> case retreatNodes of
              
              -- disband if there's no place to retreat to
              [] -> return (Disband unitPos)
              
              -- otherwise pick a random one
              nodes -> return . Retreat unitPos =<< randElem nodes

  putOrders $ Just retreatOrders

learnBrainBuild :: LearnBrainBuild ()
learnBrainBuild = do
  myPower <- getMyPower
  myUnits <- getMyUnits
  mySupplies <- getMySupplies
  provUnitMap <- getProvUnitMap

  let difference = length myUnits - length mySupplies
    
  ords <- if difference < 0
            then do
            homescs <- getMyHomeSupplies
            flip mapM (take (-difference) mySupplies) $
              \sc -> do
                if (isNothing (Map.lookup sc provUnitMap) && -- if sc is unoccupied
                    sc `elem` homescs)                       -- and is a home supply
                  then buildLearnUnit sc                    -- then build
                  else return (Waive myPower)                -- otherwise waive
                                   
            -- TODO randomise which ones to remove
            else return . map Remove $ take difference myUnits -- remove 

  -- trace ("DIFFERENCE = " ++ show difference ++ ", LENGTH(ORDERS) = " ++ show (length ords)) $
  --     trace ("MY SUPPLIES = " ++ show mySupplies) $
  --     trace ("MY UNITS = " ++ show myUnits) $
  putOrders (Just ords)

buildLearnUnit :: Province -> LearnBrainBuild OrderBuild
buildLearnUnit prov = do
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
