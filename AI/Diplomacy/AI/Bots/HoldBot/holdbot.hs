module Main where

import AI.Diplomacy.AI.SkelBot.SkelBot
import AI.Diplomacy.AI.SkelBot.Brain
import Common.Diplomacy.Common.DipMessage

data HoldDecision = HoldDecision [UnitPosition]
data DisbandDecision = DisbandDecision [UnitPosition]
data WaiveDecision Power = WaiveDecision Power

instance Decision HoldBrain HoldDecision where
  diplomise :: Decision -> [DipMessage] -- <- Maybe not actually DipMessages
  diplomise (HoldDecision units) = SubmitOrder map holdOrderForUnit units 
  diplomise (DisbandDecision units) = SubmitOrder map disbandOrderForUnit units
  diplomise (WaiveDecision power) = SubmitOrder Order OrderBuild Waive power

diplomise Hold = asd

--produces an order to hold the unit
holdOrderForUnit :: UnitPosition -> Order
holdOrderForUnit unit = Order OrderMovement Hold unit 

--produces an order to disband the unit
disbandOrderForUnit :: UnitPosition -> Order
disbandOrderForUnit unit = Order OrderRetreat Disband unit

getPower :: Power
getPower = --gets our power, from gameInfo, Slemi still hasn't pushed his changes for that >.<

type HoldBrain = BrainComm HoldDecision ()

main = skelBot holdBrain

holdBrain :: HoldBrain ()
holdBrain = do
  curMapState <- asksGameState gameStateMap
  let unitPoss = unitPositions curMapState
  let ownSupplies = getOwnSupplies $ supplyOwnerships curMapState --need to define getOwnSupplies here
  decide $ holdUnits unitPoss ownSupplies

  {-forever $ do
  # Stuff not really to do with holdbot but Luke likes keeping it here # 
  liftIO $ print "whatevs"
  unitPoss <- asksMapState unitPositions
  inMessage <- popInMessage
  
  result <- think pureBrain inMessage
  map someFunction unitPoss
-}

getOwnSupplies :: [SupplyCentreOwnership] -> [Provinces]
getOwnSupplies supplies = 
  [provinces | (power provinces) <- supplies, power = getPower]

holdUnits :: UnitPositions -> [SupplyCentreOwnership] -> Decision
holdUnits (UnitPositions Spring units) _ =
  HoldDecision units
-- tell all units to hold

holdUnits (UnitPositions Fall units) _	 =
  HoldDecision units
-- tell all units to hold

holdUnits (UnitPositionsRet Summer unitsAndRets) _ =
  retreatUnits unitsAndRets
-- need to retreat our units that need retreating
-- unitsAndRets is a list of units that need to be retreating and
-- each unit will have a corresponding list of provinces it can retreat to
-- in our holdbot case we just disband. Lol.

holdUnits (UnitPositionsRet Autumn unitsAndRets) _ =
  retreatUnits unitsAndRets
-- similar to above

holdUnits (UnitPositions Winter units) ownSupplies =
  disbandOrWaive units ownSupplies
{- need to disband if we have too many units or waive builds if we have the 
   opportunity to build i.e. we have more supply centres than units and units have         
   controlled the province for at least 2 turns 
-}

retreatUnits :: [(UnitPosition, [ProvinceNode])] -> Decision
retreatUnits unitsAndRetreats = 
  DisbandDecision [unit| (unit, _) <- unitsAndRetreats]

disbandOrWaive :: [UnitPosition] ->  [Provinces] -> Decision
disbandOrWaive units supplyCentres =
  | difference > 0 = DisbandDecision $ take difference units
  | otherwise      = WaiveDecision getPower
     {- here we need to waive a build on a unit on a province in our home territory 
        which we are still in control of and doesn't have a unit on it currently -}
    -- waive builds on all units? Technically waiving a build means not submitting any sort of build order whatsoever
  where
    difference = (length units) - (length supplyCentres)  

{- if |unitpositions| > |provinces where supply centres are| then 
   we need to disband some units as we aren't allowed more units than supply
   centres, holdbot.cpp just disbands from the beginning
   else
   we need to waive builds, we never build so we just say no thanks don't want to
   build
  UPDATE: just waive power does the same thing. BOOM.
-}

