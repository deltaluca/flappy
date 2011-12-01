
-- | Functions controlling the strategy bot; including  
-- | 
-- |   a) Measuring different aspects of game states and
-- |      storing them in an environment
-- |   b) Constructing a partial game tree with 1-level
-- |      lookahead
-- |   c) Defining a generic evaluation function in terms 
-- |      of the aspects from a)
-- | 
-- |   So once StrategyBot is asked for decision, will: 
-- | 
-- |    Do b) using a combination of c) Evaluation functions
-- |    
-- |    Output the decision with the highest MINMAX value
-- |    
-- |    Record its decision in a log for later evaluation of
-- |    the combination
-- | 

module Diplomacy.AI.SkelBot.StrategyBot

-- | Generic bot interface
import Diplomacy.AI.SkelBot.SkelBot
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Decision
import Diplomacy.AI.SkelBot.DipBot

-- | Game tree node info
import Diplomacy.AI.SkelBot.GameInfo
import Diplomacy.AI.SkelBot.GameState
import Diplomacy.Common.Data

-- | Constructing Messages 
import Diplomacy.Common.DipMessage

-- | Impure
import Control.Monad.Reader
import Control.Monad.State
import Control.Monad.Identity

import Control.Concurrent.STM

-- | -------------------------------------------------------------------------------------------

data StrategyBotDecision = StrategyDecision [UnitPosition]
                         | DisbandDecision [UnitPosition]
                         | WaiveDecision Power

type StrategyBotHistory = ()

instance Decision StrategyBotDecision where
  diplomise (StrategyDecision units) = [SubmitOrder Nothing (map holdOrderForUnit units)]
  diplomise (DisbandDecision units) = [SubmitOrder Nothing (map disbandOrderForUnit units)]
  diplomise (WaiveDecision power) = [SubmitOrder Nothing [OrderBuild (Waive power)]]

----------------------------------------------------------------------------------------------

-- | Order constructors

holdOrderForUnit :: UnitPosition -> Order
holdOrderForUnit unit = OrderMovement (Strategy unit)

disbandOrderForUnit :: UnitPosition -> Order
disbandOrderForUnit unit = OrderRetreat (Disband unit)

----------------------------------------------------------------------------------------------

type StrategyBrainCommT m = BrainCommT StrategyBotDecision () m
type StrategyBrain = Brain StrategyBotDecision ()

------

-- | TODO: Put all main functions into a separate file to enable brain 
-- |       composition

main = skelBot strategyBot

------

strategyBot :: (MonadIO m) => DipBot m StrategyBotDecision StrategyBotHistory
strategyBot = DipBot { dipBotBrainComm = strategyBrainComm
                     , dipBotProcessResults = strategyProcessResults
                     , dipBotInitHistory = strategyInitHistory }


strategyBrainComm :: (MonadIO m) => StrategyBrainCommT m ()
strategyBrainComm = liftBrain (runBrain strategyBrain)

-- | Main computation loop

strategyBrain :: StrategyBrain ()
strategyBrain = do
  curMapState <- asksGameState gameStateMap
  let unitPoss = unitPositions curMapState
  ownSupplies <- getOwnSupplies $ supplyOwnerships curMapState -- |need to define getOwnSupplies here
  myDecision <- strategyUnits unitPoss ownSupplies
  putDecision $ Just myDecision

--------------------------------------------------------------------------------
    

strategyProcessResults :: Results -> StrategyBotHistory -> StrategyBotHistory
strategyProcessResults = undefined

strategyInitHistory :: (MonadIO m) => m StrategyBotHistory
strategyInitHistory = return ()

getOwnSupplies :: [SupplyCentreOwnership] -> StrategBrain [Province]
getOwnSupplies supplies = do
  myPower <- getPower
  return . head $ [provinces | (SupplyCentre power provinces) <- supplies, myPower == power]

strategyUnits :: UnitPositions -> [Province] -> StrategyBrain StrategyBotDecision
strategyUnits (UnitPositions (Turn Spring _) units) _ = do
  myPower <- getPower    
  return $ StrategyDecision $ filter (isMyPower myPower) units
-- tell all units to strateg

strategyUnits (UnitPositions (Turn Fall _) units) _	 = do
  myPower <- getPower    
  return $ StrategyDecision $ filter (isMyPower myPower) units
-- tell all units to strategy

strategyUnits (UnitPositionsRet (Turn Summer _) unitsAndRets) _ =
  retreatUnits unitsAndRets
-- | need to retreat our units that need retreating
-- |unitsAndRets is a list of units that need to be retreating and
-- |each unit will have a corresponding list of provinces it can retreat to
-- |in our strategybot case we just disband.

strategyUnits (UnitPositionsRet (Turn Autumn _) unitsAndRets) _ =
  retreatUnits unitsAndRets
-- |similar to above

strategyUnits (UnitPositions (Turn Winter _) units) ownSupplies =
  disbandOrWaive units ownSupplies
{- |need to disband if we have too many units or waive builds if we have the 
    opportunity to build i.e. we have more supply centres than units and units have         
    controlled the province for at least 2 turns 
-}

retreatUnits :: [(UnitPosition, [ProvinceNode])] -> StrategyBrain StrategyBotDecision
retreatUnits unitsAndRetreats = do 
  let units = [unit| (unit, _) <- unitsAndRetreats]
  myPower <- getPower
  return $ DisbandDecision $ filter (isMyPower myPower) units

disbandOrWaive :: [UnitPosition] ->  [Province] -> StrategyBrain StrategyBotDecision
disbandOrWaive units supplyCentres 
  | difference > 0 = do
                        myPower <- getPower    
                        return $ DisbandDecision $ filter (isMyPower myPower) (take difference units)
  | otherwise      = do
                        myPower <- getPower
                        return $ WaiveDecision myPower
  where
    difference = (length units) - (length supplyCentres)  
     {- | here we need to waive a build on a unit on a province in our home 
          territory which we are still in control of and doesn't have a 
          unit on it currently -}
    -- | waive builds on all units? Technically waiving a build means not 
    -- | submitting any sort of build order whatsoever

--------------------------------------------------------------------------------

-- | Helpers 

-- |checks if this UnitPosition is ours (if it contains our power number)
isMyPower :: Power -> UnitPosition -> Bool
isMyPower myPower (UnitPosition power _ _) = power == myPower 

getPower :: StrategyBrain Power
getPower = asksGameInfo gameInfoPower

--------------------------------------------------------------------------------
