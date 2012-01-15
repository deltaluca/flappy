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
import Diplomacy.AI.SkelBot.CommonCache

import Diplomacy.AI.Bots.DumbBot.DumbBotInt

import Diplomacy.Common.Data

import Data.Maybe
import Data.List

import System.Random
import Control.Monad.IO.Class
import Control.Monad.Random
import Control.Monad

import qualified Data.Map as Map
import qualified Data.Traversable as Traversable

import Database.HDBC
import Database.HDBC.Sqlite3
 
main = skelBot learnBot

learnBot :: (MonadIO m, Functor m) => DipBot m LearnHistory
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
  ((), nextStdGen) <- runBrainCache $ runRandT brain stdGen
  liftIO $ setStdGen nextStdGen  -- set new stdgen

learnBrainMoveComm :: (MonadIO m, Functor m) => BrainCommT OrderMovement LearnHistory m ()
learnBrainMoveComm =  do
--  mapBrainCommTHist (const ()) dumbBrainMoveComm

  withStdGen learnBrainMove

learnBrainRetreatComm :: (MonadIO m) => BrainCommT OrderRetreat LearnHistory m ()
learnBrainRetreatComm = withStdGen learnBrainRetreat

learnBrainBuildComm :: (MonadIO m) => BrainCommT OrderBuild LearnHistory m ()
learnBrainBuildComm = withStdGen learnBrainBuild

learnBrainMove :: (MonadIO m) => LearnBrainMoveT m ()
learnBrainMove = do
  gameEnd <- learnBrainEnd
  if gameEnd
    then do
      learnGameOverEarly
      putOrders Nothing
    else do

      dumbOrders <- getOrders
      myUnits <- getMyUnits
      legalUnitMoves <- foldM genLegalOrders Map.empty myUnits
      trimmedOrders <- mapM ((randElems _trimNum) . (legalUnitMoves Map.!)) myUnits
  
      let possibleOrderSets = case dumbOrders of
                                Just o -> [o]
                                Nothing -> Traversable.sequenceA trimmedOrders 

      brainLog $ show $ (dumbOrders, length possibleOrderSets)
      highestWeightedOrders <- weighOrderSets possibleOrderSets
      orders <- randWeightedElem $ take 5 highestWeightedOrders
      putOrders $ Just orders

learnGameOverEarly :: (MonadIO m) => LearnBrainMoveT m ()
learnGameOverEarly = do
  hist <- getHistory
  myPower <- getMyPower
  supplies <- getSupplies myPower
  if (length supplies == _noOfSCNeededToWin) then brainLog (show "I won, YAY!") else brainLog (show "I didn't win :(")
  conn <- liftIO $ connectSqlite3 _dbname
  let finalDB = applyTDiffEnd (applyTDiffTurn (getPureDB hist) (getHist hist)) $ snd $ unzip (getHist hist)
  putPureDBAnalysis undefined finalDB

  let myTable = undefined

  liftIO $ commitPureDB conn finalDB myTable
  liftIO $ commit conn
  liftIO $ disconnect conn
  brainLog $ show $ "Commit done early :D"
  return ()

learnGameOver :: (MonadIO m) => GameKnowledgeT LearnHistory m ()
learnGameOver = do
  hist <- getHistory
  conn <- liftIO $ connectSqlite3 _dbname
  let finalDB = applyTDiffEnd (applyTDiffTurn (getPureDB hist) (getHist hist)) $ snd $ unzip (getHist hist)

  let myTable = undefined

  liftIO $ commitPureDB conn finalDB myTable
  liftIO $ commit conn
  liftIO $ disconnect conn
  liftIO $ putStrLn $ "Commit done :)"
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

  myTable <- undefined

  pureDB <- liftIO $ makeAndFillPureDB conn myTable
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
      return $ UnitPosition myPower utyp (ProvNode prov)
    BiCoastal -> do
      provNode <- randElem (provToProvNodes Map.! prov)
      case provNode of
        ProvNode _ -> return $ UnitPosition myPower Army provNode
        ProvCoastNode _ _ -> return $ UnitPosition myPower Fleet provNode
