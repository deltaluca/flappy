module Main where

import Diplomacy.AI.SkelBot.SkelBot
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Decision
import Diplomacy.AI.SkelBot.GameInfo
import Diplomacy.AI.SkelBot.GameState
import Diplomacy.AI.SkelBot.DipBot
import Diplomacy.Common.DipMessage
import Diplomacy.Common.Data
import Control.Monad.Reader
import Control.Monad.State
import Control.Monad.Identity

data HoldBotDecision = HoldDecision [UnitPosition]
                     | DisbandDecision [UnitPosition]
                     | WaiveDecision Power

type HoldBotHistory = ()

instance Decision HoldBotDecision where
  diplomise (HoldDecision units) = [SubmitOrder Nothing (map holdOrderForUnit units)]
  diplomise (DisbandDecision units) = [SubmitOrder Nothing (map disbandOrderForUnit units)]
  diplomise (WaiveDecision power) = [SubmitOrder Nothing [OrderBuild (Waive power)]]


--produces an order to hold the unit
holdOrderForUnit :: UnitPosition -> Order
holdOrderForUnit unit = OrderMovement (Hold unit)

--produces an order to disband the unit
disbandOrderForUnit :: UnitPosition -> Order
disbandOrderForUnit unit = OrderRetreat (Disband unit)

getPower :: HoldBrain Power
getPower = asksGameInfo gameInfoPower
{-
do
  let a = someFunction
  b :: a <- someOtherFunction :: m a
  return :: a -> m a
  (>>=) :: m a -> (a -> m b) -> m b

  a <- f
  b <- g a
  c <- h b

  c <- h =<< (g =<< f :: m b)
  return c

  f >>= (\a -> g a >>= (\b -> h b >>= \c -> return c)) -}

type HoldBrainCommT m = BrainCommT HoldBotDecision () m
type HoldBrain = Brain HoldBotDecision ()

main = skelBot holdBot

holdBot :: (MonadIO m) => DipBot m HoldBotDecision HoldBotHistory
holdBot = DipBot { dipBotBrainComm = holdBrainComm
                 , dipBotProcessResults = holdProcessResults
                 , dipBotInitHistory = holdInitHistory }


holdBrainComm :: (MonadIO m) => HoldBrainCommT m ()
holdBrainComm = liftBrain (runBrain holdBrain)

holdBrain :: HoldBrain ()
holdBrain = do
  curMapState <- asksGameState gameStateMap
  let unitPoss = unitPositions curMapState
  ownSupplies <- getOwnSupplies $ supplyOwnerships curMapState --need to define getOwnSupplies here
  myDecision <- holdUnits unitPoss ownSupplies
  putDecision $ Just myDecision

--decide . holdUnits unitPoss =<< ownSupplies
  
  {-do
  supplies <- ownSupplies
  let h = holdUnits unitposs supplies)-}
    

holdProcessResults :: Results -> HoldBotHistory -> HoldBotHistory
holdProcessResults = undefined

holdInitHistory :: (MonadIO m) => m HoldBotHistory
holdInitHistory = return ()

  {-forever $ do
  # Stuff not really to do with holdbot but Luke likes keeping it here # 
  liftIO $ print "whatevs"
  unitPoss <- asksMapState unitPositions
  inMessage <- popInMessage
  
  result <- think pureBrain inMessage
  map someFunction unitPoss
-}

getOwnSupplies :: [SupplyCentreOwnership] -> HoldBrain [Province]
getOwnSupplies supplies = do
  myPower <- getPower
  return . head $ [provinces | (SupplyCentre power provinces) <- supplies, myPower == power]

holdUnits :: UnitPositions -> [Province] -> HoldBrain HoldBotDecision
holdUnits (UnitPositions (Turn Spring _) units) _ = do
  myPower <- getPower    
  return $ HoldDecision $ filter (isMyPower myPower) units
-- tell all units to hold

holdUnits (UnitPositions (Turn Fall _) units) _	 = do
  myPower <- getPower    
  return $ HoldDecision $ filter (isMyPower myPower) units
-- tell all units to hold

holdUnits (UnitPositionsRet (Turn Summer _) unitsAndRets) _ =
  retreatUnits unitsAndRets
-- need to retreat our units that need retreating
-- unitsAndRets is a list of units that need to be retreating and
-- each unit will have a corresponding list of provinces it can retreat to
-- in our holdbot case we just disband.

holdUnits (UnitPositionsRet (Turn Autumn _) unitsAndRets) _ =
  retreatUnits unitsAndRets
-- similar to above

holdUnits (UnitPositions (Turn Winter _) units) ownSupplies =
  disbandOrWaive units ownSupplies
{- need to disband if we have too many units or waive builds if we have the 
   opportunity to build i.e. we have more supply centres than units and units have         
   controlled the province for at least 2 turns 
-}

retreatUnits :: [(UnitPosition, [ProvinceNode])] -> HoldBrain HoldBotDecision
retreatUnits unitsAndRetreats = do 
  let units = [unit| (unit, _) <- unitsAndRetreats]
  myPower <- getPower
  return $ DisbandDecision $ filter (isMyPower myPower) units

disbandOrWaive :: [UnitPosition] ->  [Province] -> HoldBrain HoldBotDecision
disbandOrWaive units supplyCentres 
  | difference > 0 = do
                        myPower <- getPower    
                        return $ DisbandDecision $ filter (isMyPower myPower) (take difference units)
  | otherwise      = do
                        myPower <- getPower
                        return $ WaiveDecision myPower
  where
    difference = (length units) - (length supplyCentres)  
     {- here we need to waive a build on a unit on a province in our home territory 
        which we are still in control of and doesn't have a unit on it currently -}
    -- waive builds on all units? Technically waiving a build means not submitting any sort of build order whatsoever

--checks if this UnitPosition is ours (if it contains our power number)
isMyPower :: Power -> UnitPosition -> Bool
isMyPower myPower (UnitPosition power _ _) = power == myPower 

