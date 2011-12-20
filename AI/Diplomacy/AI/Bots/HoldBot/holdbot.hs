module Main where

import Diplomacy.AI.SkelBot.SkelBot
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.DipBot
import Diplomacy.AI.SkelBot.Common
import Diplomacy.Common.Data

import Data.Map as Map hiding (map, filter)
import Control.Monad.Trans

-- pure brains
type HoldBrain o = Brain o ()

type HoldBrainMove = HoldBrain OrderMovement
type HoldBrainRetreat = HoldBrain OrderRetreat
type HoldBrainBuild = HoldBrain OrderBuild

-- impure brains
type HoldBrainCommT o = BrainCommT o ()

type HoldBrainMoveCommT = HoldBrainCommT OrderMovement
type HoldBrainRetreatCommT = HoldBrainCommT OrderRetreat
type HoldBrainBuildCommT = HoldBrainCommT OrderBuild

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
holdBrainComm :: (MonadIO m, OrderClass o) => HoldBrain o () -> HoldBrainCommT o m ()
holdBrainComm pureBrain = liftBrain (runBrain pureBrain)

holdBrainMoveComm :: (MonadIO m) => HoldBrainMoveCommT m ()
holdBrainMoveComm = holdBrainComm holdBrainMove

holdBrainRetreatComm :: (MonadIO m) => HoldBrainRetreatCommT m ()
holdBrainRetreatComm = holdBrainComm holdBrainRetreat

holdBrainBuildComm :: (MonadIO m) => HoldBrainBuildCommT m ()
holdBrainBuildComm = holdBrainComm holdBrainBuild

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


