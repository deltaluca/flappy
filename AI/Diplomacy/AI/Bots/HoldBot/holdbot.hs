module Main where

import Diplomacy.AI.SkelBot.SkelBot
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.GameInfo
import Diplomacy.AI.SkelBot.DipBot
import Diplomacy.Common.DipMessage
import Diplomacy.Common.Data

import Data.Map as Map hiding (map, filter)
import Control.Monad.Trans

--produces an order to hold the unit
holdOrderForUnit :: UnitPosition -> OrderMovement
holdOrderForUnit unit = (Hold unit)

--produces an order to disband the unit during summer/autumn phase
disbandOrderForUnit :: UnitPosition -> OrderRetreat
disbandOrderForUnit unit = (Disband unit)

--produces an order to disband the unit during winter phase 
removeOrderForUnit :: UnitPosition -> OrderBuild
removeOrderForUnit unit = (Remove unit)

getPower :: (OrderClass o) => HoldBrain o Power
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

type HoldBrainMoveCommT m = BrainCommT OrderMovement () m
type HoldBrain o = Brain o ()
type HoldBrainMove = Brain OrderMovement ()
type HoldBrainRetreat = Brain OrderRetreat ()
type HoldBrainBuild = Brain OrderBuild ()


main = skelBot holdBot

holdBot :: (MonadIO m) => DipBot m ()
holdBot = DipBot { dipBotName = "FlappyHoldBot"
                 , dipBotVersion = 0.1
                 , dipBotBrainMovement = holdBrainMovement
                 , dipBotBrainRetreat = holdBrainRetreat
                 , dipBotBrainBuild = holdBrainBuild
                 , dipBotProcessResults = holdProcessResults
                 , dipBotInitHistory = holdInitHistory }


holdBrainMovement :: (MonadIO m) => HoldBrainMoveCommT m ()
holdBrainMovement = liftBrain (runBrain holdBrainMove)

holdBrainMove :: HoldBrainMove ()
holdBrainMove = do
  curMapState <- asksGameState gameStateMap
  let unitPoss = unitPositions curMapState
  units <- holdUnitsMove unitPoss
  putOrders $ Just (map holdOrderForUnit units)

holdBrainRetreat :: HoldBrainRetreat ()
holdBrainRetreat = do
  curMapState <- asksGameState gameStateMap
  let unitPoss = unitPositions curMapState
  units <- holdUnitsRetreat unitPoss
  putOrders $ Just (map disbandOrderForUnit units)
  
holdBrainBuild :: HoldBrainBuild ()
holdBrainBuild = do
  curMapState <- asksGameState gameStateMap
  let unitPoss = unitPositions curMapState
  ownSupplies <- getOwnSupplies $ supplyOwnerships curMapState --need to define getOwnSupplies here
  e <- holdUnitsBuild unitPoss ownSupplies
  putOrders $ Just (either
                      (\units -> map removeOrderForUnit units)
                      (\power -> [Waive power]) e)

--decide . holdUnits unitPoss =<< ownSupplies
  
  {-do
  supplies <- ownSupplies
  let h = holdUnits unitposs supplies)-}
    

holdProcessResults :: Results -> () -> ()
holdProcessResults = error "holdProcessResults not implemented"

holdInitHistory :: (MonadIO m) => m ()
holdInitHistory = return ()

  {-forever $ do
  # Stuff not really to do with holdbot but Luke likes keeping it here # 
  liftIO $ print "whatevs"
  unitPoss <- asksMapState unitPositions
  inMessage <- popInMessage
  
  result <- think pureBrain inMessage
  map someFunction unitPoss
-}

getOwnSupplies :: (OrderClass o) => SupplyCOwnerships -> HoldBrain o [Province]
getOwnSupplies (SupplyCOwnerships supplies) = do
  myPower <- getPower
  return . head $ [provinces | (power, provinces) <- toList supplies, myPower == power]

holdUnitsMove :: UnitPositions -> HoldBrainMove [UnitPosition]
holdUnitsMove (UnitPositions (Turn Spring _) units) = do
  myPower <- getPower    
  return $ filter (isMyPower myPower) units
-- tell all units to hold

holdUnitsMove (UnitPositions (Turn Fall _) units)	 = do
  myPower <- getPower    
  return $ filter (isMyPower myPower) units
-- tell all units to hold

holdUnitsMove _ = error "Wrong phase(MOVE)"

holdUnitsRetreat :: UnitPositions -> HoldBrainRetreat [UnitPosition]
holdUnitsRetreat (UnitPositionsRet (Turn Summer _) unitsAndRets) =
  retreatUnits unitsAndRets
-- need to retreat our units that need retreating
-- unitsAndRets is a list of units that need to be retreating and
-- each unit will have a corresponding list of provinces it can retreat to
-- in our holdbot case we just disband.

holdUnitsRetreat (UnitPositionsRet (Turn Autumn _) unitsAndRets) =
  retreatUnits unitsAndRets
-- similar to above

holdUnitsRetreat _ = error "Wrong phase(RETREAT)"

holdUnitsBuild :: UnitPositions -> [Province] -> HoldBrainBuild (Either [UnitPosition] Power)
holdUnitsBuild (UnitPositions (Turn Winter _) units) ownSupplies =
  removeOrWaive units ownSupplies
{- need to disband if we have too many units or waive builds if we have the 
   opportunity to build i.e. we have more supply centres than units and units have         
   controlled the province for at least 2 turns 
-}
holdUnitsBuild _ _ = error "Wrong phase(BUILD)"

retreatUnits :: [(UnitPosition, [ProvinceNode])] -> HoldBrainRetreat [UnitPosition]
retreatUnits unitsAndRetreats = do 
  let units = [unit| (unit, _) <- unitsAndRetreats]
  myPower <- getPower
  return $ filter (isMyPower myPower) units

removeOrWaive :: [UnitPosition] ->  [Province] -> HoldBrainBuild (Either [UnitPosition] Power)
removeOrWaive units supplyCentres 
  | difference > 0 = do
                        myPower <- getPower    
                        return $ Left $ filter (isMyPower myPower) (take difference units)
  | otherwise      = do
                        myPower <- getPower
                        return $ Right myPower
  where
    difference = (length units) - (length supplyCentres)  
     {- here we need to waive a build on a unit on a province in our home territory 
        which we are still in control of and doesn't have a unit on it currently -}
    -- waive builds on all units? Technically waiving a build means not submitting any sort of build order whatsoever

--checks if this UnitPosition is ours (if it contains our power number)
isMyPower :: Power -> UnitPosition -> Bool
isMyPower myPower (UnitPosition power _ _) = power == myPower 

