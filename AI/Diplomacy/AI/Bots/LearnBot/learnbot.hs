{- |
-------------------------- LEARNBOT ------------------------------

-}

module Main where

import Diplomacy.AI.Bots.LearnBot.PatternWeights
import Diplomacy.AI.Bots.LearnBot.Monad

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

import Database.HDBC
import Database.HDBC.Sqlite3
 
main = skelBot learnBot

learnBot :: (MonadIO m) => DipBot m LearnHistory
learnBot = DipBot { dipBotName = "FlappyLearningBot"
                  , dipBotVersion = 0.1
                  , dipBotBrainMovement = learnBrainMoveComm
                  , dipBotBrainRetreat = learnBrainRetreatComm
                  , dipBotBrainBuild = learnBrainBuildComm
                  , dipBotProcessResults = learnProcessResults
                  , dipBotInitHistory = learnInitHistory
                  , dipBotGameOver = learnGameOver }


withStdGen :: (MonadIO m, OrderClass o) => LearnBrainT o m () -> BrainCommT o LearnHistory m ()
withStdGen brain = do
  stdGen <- liftIO getStdGen
  ((), nextStdGen) <- runRandT brain $ stdGen
  liftIO $ setStdGen nextStdGen  -- set new stdgen

learnBrainMoveComm :: (MonadIO m) => BrainCommT OrderMovement LearnHistory m ()
learnBrainMoveComm = withStdGen learnBrainMove

learnBrainRetreatComm :: (MonadIO m) => BrainCommT OrderRetreat LearnHistory m ()
learnBrainRetreatComm = withStdGen learnBrainRetreat

learnBrainBuildComm :: (MonadIO m) => BrainCommT OrderBuild LearnHistory m ()
learnBrainBuildComm = withStdGen learnBrainBuild

learnBrainMove :: (MonadIO m) => LearnBrainMoveT m ()
learnBrainMove = do 
  myUnits <- getMyUnits
  --obtain all legal moves
  legalUnitMoves <- foldM genLegalOrders Map.empty myUnits
	
  trimmedOrders <- mapM ((randElems _trimNum) . (legalUnitMoves Map.!)) myUnits
  let possibleOrderSets = Traversable.sequenceA trimmedOrders
  brainLog $ show $ length possibleOrderSets
  highestWeightedOrders <- weighOrderSets possibleOrderSets
  orders <- randWeightedElem $ take 5 highestWeightedOrders
  putOrders $ Just orders

learnGameOver :: (MonadIO m) => GameKnowledgeT LearnHistory m ()
learnGameOver = do
  hist <- getHistory
  conn <- liftIO $ connectSqlite3 _dbname
  liftIO $ commitPureDB conn (getPureDB hist)
  liftIO $ applyTDiffEnd conn $ (\(x, y) -> y) $ unzip (getHist hist)
  liftIO $ applyTDiffTurn conn (getHist hist)
  liftIO $ commit conn
  liftIO $ disconnect conn
  return ()

learnBrainEnd :: (MonadIO m, MonadGameKnowledge h m, MonadBrain o m) => m Bool
learnBrainEnd = do
  myPower <- getMyPower
  UnitPositions up <- asksGameState (unitPositions.gameStateMap)
  supplies <- getSupplies myPower
  let lost = ((length supplies == 0) && isNothing (Map.lookup myPower up))
  powers <- asksGameInfo (mapDefPowers.gameInfoMapDef)
  powSuppNums <- sequence $ [(return.length) =<< (getSupplies p) | p <- powers]  
  return $ (lost ||) $(>0) $ length $ filter (>= _noOfSCNeededToWin) powSuppNums

learnProcessResults _ = id

learnInitHistory :: (MonadIO m) => GameInfo -> GameState -> m LearnHistory
learnInitHistory _ _ = do
  conn <- liftIO $ connectSqlite3 _dbname
  pureDB <- liftIO $ makeAndFillPureDB conn
  liftIO $ commit conn
  liftIO $ disconnect conn
  return $ LearnHistory pureDB []

learnBrainRetreat :: (MonadIO m) => LearnBrainRetreatT m ()
learnBrainRetreat = do
  myRetreats <- getMyRetreats
  retreatOrders <- flip mapM myRetreats
            $ \(unitPos, retreatNodes) -> case retreatNodes of
              
              -- disband if there's no place to retreat to
              [] -> return (Disband unitPos)
              
              -- otherwise pick a random one
              nodes -> return . Retreat unitPos =<< randElem nodes

  putOrders $ Just retreatOrders

learnBrainBuild :: (MonadIO m) =>  LearnBrainBuildT m ()
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

buildLearnUnit :: (MonadIO m) => Province -> LearnBrainBuildT m OrderBuild
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
