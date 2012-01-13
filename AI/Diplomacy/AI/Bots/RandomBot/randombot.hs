{- |
-------------------------- RANDOMBOT ------------------------------

  RandomBot is built on HoldBot, all the retreat and disband 
  decisions behave in roughly the same way, the differences are:
        -- Instead of holding all units for every move turn
           (i.e. spring or fall), we will randomly choose a
           Move move (move units from one province to another)
           and submit this as our move. 
              -> This means that we are going to have to 
                 determine what valid moves we can make,
                 and choose a random one.
                    ---> We can start with finding valid Move moves
                    ---> Maybe add random Defend moves aswell  
        -- During the winter turn, if we have the opportunity to 
           build (i.e. less units than supply centres and our 
           supply centres in our home country are currently 
           unoccupied) then we will build new units in these 
           supply centres and send our build orders to the server 
-}

{-# LANGUAGE TypeSynonymInstances, FlexibleInstances, MultiParamTypeClasses #-}

module Main where

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

import qualified Data.Map as Map

-- pure brains
type RandomBrain o = RandT StdGen (BrainCacheT (Brain o ()))

type RandomBrainMove = RandomBrain OrderMovement
type RandomBrainRetreat = RandomBrain OrderRetreat
type RandomBrainBuild = RandomBrain OrderBuild

-- impure brains
type RandomBrainCommT o = BrainCommT o ()

type RandomBrainMoveCommT = BrainCommT OrderMovement ()
type RandomBrainRetreatCommT = BrainCommT OrderRetreat ()
type RandomBrainBuildCommT = BrainCommT OrderBuild ()

instance (OrderClass o) => MonadBrainCache (RandomBrain o) where
  askCache = lift askCache

instance (OrderClass o) => MonadBrain o (RandomBrain o) where
  asksGameState = lift . asksGameState
  getsOrders = lift . getsOrders
  putOrders = lift . putOrders

instance (OrderClass o) => MonadGameKnowledge () (RandomBrain o) where
  asksGameInfo = lift . asksGameInfo
  getsHistory = lift . getsHistory
  putHistory = lift . putHistory
  
_SEED = 0 :: Int

main = do
  --setStdGen (mkStdGen _SEED) >>
  skelBot randomBot

randomBot :: (MonadIO m) => DipBot m ()
randomBot = DipBot { dipBotName = "FlappyRandomBot"
                   , dipBotVersion = 0.1
                   , dipBotBrainMovement = randomBrainMoveComm
                   , dipBotBrainRetreat = randomBrainRetreatComm
                   , dipBotBrainBuild = randomBrainBuildComm
                   , dipBotProcessResults = randomProcessResults
                   , dipBotInitHistory = randomInitHistory
                   , dipBotGameOver = randomGameOver }

randomGameOver :: (MonadIO m) => GameKnowledgeT () m ()
randomGameOver = return ()

randomBrainComm :: (MonadIO m, OrderClass o) => RandomBrain o () -> RandomBrainCommT o m ()
randomBrainComm brain = do
  stdGen <- liftIO getStdGen
  
  (_, nextStdGen) <- liftBrain   -- lift pure brain
    . runBrain                  -- no underlying monad
    . runBrainCache
    . runRandT brain $ stdGen
  
  liftIO $ setStdGen nextStdGen  -- set new stdgen

randomBrainMoveComm :: (MonadIO m) => RandomBrainMoveCommT m ()
randomBrainMoveComm = randomBrainComm randomBrainMove

randomBrainRetreatComm :: (MonadIO m) => RandomBrainRetreatCommT m ()
randomBrainRetreatComm = randomBrainComm randomBrainRetreat

randomBrainBuildComm :: (MonadIO m) => RandomBrainBuildCommT m ()
randomBrainBuildComm = randomBrainComm randomBrainBuild

randomProcessResults :: [(Order, OrderResult)] -> () -> ()
randomProcessResults _ = id

randomInitHistory :: (MonadIO m) => GameInfo -> GameState -> m ()
randomInitHistory _ _ = return ()

randomBrainMove :: RandomBrainMove ()
randomBrainMove = do
  movementOrders <- foldM randomUnitsMovement [] =<< getMyUnits
  putOrders $ Just movementOrders

randomUnitsMovement :: [OrderMovement] -> UnitPosition -> RandomBrainMove [OrderMovement]
randomUnitsMovement currOrders unitPos = do
  adjacentNodes <- getAdjacentNodes unitPos
  provUnitMap <- getProvUnitMap
  myPower <- getMyPower

  -- nodes being moved to by other units
  let movedTo = mapMaybe (\mo -> case mo of
                             Move u node -> Just (u, node)
                             _ -> Nothing) currOrders
  
  -- possible support moves
  let supportMoves = [ SupportMove unitPos otherUnit (provNodeToProv node1)
                     | node1 <- adjacentNodes
                     , (otherUnit, node2) <- movedTo
                     , node1 == node2 ]
  
  let adjUnits = [ otherUnit
        	 | otherPos <- adjacentNodes
                 , otherUnit <- maybeToList $
                                provNodeToProv otherPos `Map.lookup` provUnitMap
        	 , unitPositionP otherUnit == myPower ] 

  -- own units that are holding
  let holdOrders = mapMaybe (\ho -> case ho of 
        		      Hold u -> Just u
        		      _ -> Nothing) currOrders

  let supportHolds = [ SupportHold unitPos otherUnit
        	     | otherUnit <- adjUnits
        	     , holdUnit <- holdOrders
                     , holdUnit == otherUnit ]
    
  -- possible simple moves
  let moveMoves = map (Move unitPos) adjacentNodes

  -- hold move
  let holdMoves = [Hold unitPos]

  -- TODO: create convoy moves here and add them to allMoves below
  -- let convoyMoves = ...
  
  -- choose a move randomly and append it to the rest
  let allMoves = supportMoves ++ moveMoves ++ holdMoves ++ supportHolds
  order <- randElem allMoves
  return $ order : currOrders
  
randomBrainRetreat :: RandomBrainRetreat ()
randomBrainRetreat = do
  myRetreats <- getMyRetreats
  retreatOrders <- flip mapM myRetreats
            $ \(unitPos, retreatNodes) -> case retreatNodes of
              
              -- disband if there's no place to retreat to
              [] -> return (Disband unitPos)
              
              -- otherwise pick a random one
              nodes -> return . Retreat unitPos =<< randElem nodes

  putOrders $ Just retreatOrders

randomBrainBuild :: RandomBrainBuild ()
randomBrainBuild = do
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
                  then buildRandomUnit sc                    -- then build
                  else return (Waive myPower)                -- otherwise waive
                                   
            -- TODO randomise which ones to remove
            else return . map Remove $ take difference myUnits -- remove 

  -- trace ("DIFFERENCE = " ++ show difference ++ ", LENGTH(ORDERS) = " ++ show (length ords)) $
  --     trace ("MY SUPPLIES = " ++ show mySupplies) $
  --     trace ("MY UNITS = " ++ show myUnits) $
  putOrders (Just ords)

buildRandomUnit :: Province -> RandomBrainBuild OrderBuild
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
