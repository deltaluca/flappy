module Main where

import Diplomacy.AI.SkelBot.SkelBot

data HoldDecision = HoldDecision [Unit]
data DisbandDecision = DisbandDecision [Unit]
data WaiveDecision = WaiveDecision [Unit]
data WaivenDisband = WaivenDisband WaiveDecision DisbandDecision -- <- may not work, is ugly, fix it for me Cliff you gay

instance Decision HoldBrain HoldDecision where
  diplomise :: Decision -> [DipMessage] -- <- Maybe not actually DipMessages
  diplomise (HoldDecision units) = functionThatWritesHoldOrderForEachUnit


diplomise Hold = asd

type HoldBrain = BrainComm HoldDecision ()

main = skelBot holdBrain

holdBrain :: HoldBrain ()
holdBrain = do
  curMapState <- askMapState
  unitPoss <- unitPositions curMapState
  ownSupplies <- getOwnSupplies $ supplyOwnerships curMapState
  decide $ holdUnits unitPoss ownSupplies

  {-forever $ do
  # Stuff not really to do with holdbot but Luke likes keeping it here # 
  liftIO $ print "whatevs"
  unitPoss <- asksMapState unitPositions
  inMessage <- popInMessage
  
  result <- think pureBrain inMessage
  map someFunction unitPoss
-}

holdUnits :: UnitPositions -> [SupplyCentreOwnership] -> Decision
holdUnits (UnitPositions Spring units) _ =
  HoldDecision units

holdUnits (UnitPositions Fall units) _	 =
  HoldDecision units

holdUnits (UnitPositionsRet Summer unitsAndRets) _ =
  retreatAllUnitsThatNeedRetreating unitsAndRets

holdUnits (UnitPositionsRet Autumn unitsAndRets) _ =
  retreatAllUnitsThatNeedRetreating unitsAndRets

holdUnits (UnitPositions Winter units) ownSupplies =
  checkSuppliesAndDisbandOrWaive units ownSupplies
