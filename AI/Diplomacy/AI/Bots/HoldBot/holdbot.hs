module Main where

import Diplomacy.AI.SkelBot.SkelBot
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.DipBot
import Diplomacy.AI.SkelBot.Common
import Diplomacy.Common.Data

import Data.Map as Map hiding (map, filter)
import Control.Monad.Trans

-- pure brains
type HoldBrainMove = Brain OrderMovement ()
type HoldBrainRetreat = Brain OrderRetreat ()
type HoldBrainBuild = Brain OrderBuild ()

-- impure brains
type HoldBrainMoveCommT = BrainCommT OrderMovement ()
type HoldBrainRetreatCommT = BrainCommT OrderRetreat ()
type HoldBrainBuildCommT = BrainCommT OrderBuild ()

main = skelBot holdBot

holdBot :: (MonadIO m) => DipBot m ()
holdBot = DipBot { dipBotName = "FlappyHoldBot"
                 , dipBotVersion = 0.1
                 , dipBotBrainMovement = holdBrainMoveComm
                 , dipBotBrainRetreat = holdBrainRetreatComm
                 , dipBotBrainBuild = holdBrainBuildComm
                 , dipBotProcessResults = holdProcessResults
                 , dipBotInitHistory = holdInitHistory }

-- no impure actions, running pure brain
holdBrainMoveComm :: (MonadIO m) => HoldBrainMoveCommT m ()
holdBrainMoveComm = liftBrain (runBrain holdBrainMove)

holdBrainRetreatComm :: (MonadIO m) => HoldBrainRetreatCommT m ()
holdBrainRetreatComm = liftBrain (runBrain holdBrainRetreat)

holdBrainBuildComm :: (MonadIO m) => HoldBrainBuildCommT m ()
holdBrainBuildComm = liftBrain (runBrain holdBrainBuild)

-- pure decisions
holdBrainMove :: HoldBrainMove ()
holdBrainMove = do
  myUnits <- getMyUnits
  putOrders $ Just (map Hold myUnits)

holdBrainRetreat :: HoldBrainRetreat ()
holdBrainRetreat = do
  myUnits <- getMyUnits
  putOrders $ Just (map Disband myUnits)
  
holdBrainBuild :: HoldBrainBuild ()
holdBrainBuild = do
  myUnits <- getMyUnits
  mySupplies <- getMySupplies
  myPower <- getMyPower
  
  let difference = length myUnits - length mySupplies
  let orders = if difference > 0
               then map Remove (take difference myUnits)
               else [Waive myPower]
  putOrders $ Just orders

holdProcessResults :: [(Order, OrderResult)] -> () -> ()
holdProcessResults _ = id

holdInitHistory :: (MonadIO m) => m ()
holdInitHistory = return ()


