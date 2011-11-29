{-
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

{-# LANGUAGE TypeSynonymInstances, MultiParamTypeClasses #-}

module Main where

import Diplomacy.AI.SkelBot.SkelBot
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Decision
import Diplomacy.AI.SkelBot.GameInfo
import Diplomacy.AI.SkelBot.GameState
import Diplomacy.AI.SkelBot.DipBot

import Diplomacy.Common.DipMessage
import Diplomacy.Common.Data

import System.Random
import Control.Monad.Reader
import Control.Monad.State
import Control.Monad.Identity
import Control.Monad.Random

data RandomBotDecision = RandomMoveDecision [(UnitPosition,ProvinceNode)]
                     | DisbandDecision [UnitPosition]
                     | WaiveDecision Power

type RandomBotHistory = ()

instance Decision RandomBotDecision where
  diplomise (RandomMoveDecision units) = [SubmitOrder Nothing (map randomOrderForUnit units)]
  diplomise (DisbandDecision units) = [SubmitOrder Nothing (map disbandOrderForUnit units)]
  diplomise (WaiveDecision power) = [SubmitOrder Nothing [OrderBuild (Waive power)]]


--produces a random order for each unit
randomOrderForUnit :: (UnitPosition,ProvinceNode) -> Order
randomOrderForUnit (unit,provinceNode) = OrderMovement (Move unit provinceNode)

--produces an order to disband the unit
disbandOrderForUnit :: UnitPosition -> Order
disbandOrderForUnit unit = OrderRetreat (Disband unit)

getPower :: RandomBrain Power
getPower = asksGameInfo gameInfoPower

getMapDef :: RandomBrain MapDefinition  
getMapDef = asksGameInfo gameInfoMapDef --returns the mapDefinition


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

type RandomBrainCommT m = RandT StdGen (BrainCommT RandomBotDecision () m)
type RandomBrain = RandT StdGen (Brain RandomBotDecision ())

instance MonadBrain RandomBotDecision RandomBrain where
  asksGameState = lift . asksGameState
  getsDecision = lift . getsDecision
  putDecision = lift . putDecision

instance MonadGameKnowledge () RandomBrain where
  asksGameInfo = lift . asksGameInfo
  getsHistory = lift . getsHistory
  putHistory = lift . putHistory
  
main = skelBot randomBot

randomBot :: (MonadIO m) => DipBot m RandomBotDecision RandomBotHistory
randomBot = DipBot { dipBotBrainComm = randomBrainComm
                 , dipBotProcessResults = randomProcessResults
                 , dipBotInitHistory = randomInitHistory }


randomBrainComm :: (MonadIO m) => BrainCommT RandomBotDecision () m ()
randomBrainComm = do
  stdGen <- liftIO getStdGen
  liftBrain (runBrain (liftM fst (runRandT randomBrain stdGen)))

randomBrain :: RandomBrain ()
randomBrain = do
  curMapState <- asksGameState gameStateMap --returns our mapState
  mapDef <- getMapDef --get map definition
  let unitPoss = unitPositions curMapState
  let supplyOwns = supplyOwnerships curMapState
  ownSupplies <- getOwnSupplies supplyOwns --need to define getOwnSupplies here
  myDecision <- randomProcessUnits unitPoss ownSupplies mapDef
  putDecision $ Just myDecision

--decide . RandomUnits unitPoss =<< ownSupplies
  
  {-do
  supplies <- ownSupplies
  let h = RandomUnits unitposs supplies)-}
    

randomProcessResults :: Results -> RandomBotHistory -> RandomBotHistory
randomProcessResults = undefined

randomInitHistory :: (MonadIO m) => m RandomBotHistory
randomInitHistory = return ()

  {-forever $ do
  # Stuff not really to do with Randombot but Luke likes keeping it here # 
  liftIO $ print "whatevs"
  unitPoss <- asksMapState unitPositions
  inMessage <- popInMessage
  
  result <- think pureBrain inMessage
  map someFunction unitPoss
-}

getOwnSupplies :: [SupplyCentreOwnership] -> RandomBrain [Province]
getOwnSupplies supplies = do
  myPower <- getPower
  return . head $ [provinces | (SupplyCentre power provinces) <- supplies, myPower == power]

-- [province] here is the provinces where we own supply centres
randomProcessUnits :: UnitPositions -> [Province] -> MapDefinition -> RandomBrain RandomBotDecision
randomProcessUnits (UnitPositions (Turn Spring _) units) _ mapDef = do
  myPower <- getPower    
  getRandomMove (filter (isMyPower myPower) units) mapDef
-- returns as RandomDecision

randomProcessUnits (UnitPositions (Turn Fall _) units) _ mapDef = do
  myPower <- getPower    
  getRandomMove (filter (isMyPower myPower) units) mapDef
-- returns as RandomMoveDecision

randomProcessUnits (UnitPositionsRet (Turn Summer _) unitsAndRets) _ _ =
  retreatUnits unitsAndRets
-- need to retreat our units that need retreating
-- unitsAndRets is a list of units that need to be retreating and
-- each unit will have a corresponding list of provinces it can retreat to
-- in our Randombot case we just disband.

randomProcessUnits (UnitPositionsRet (Turn Autumn _) unitsAndRets) _ _ =
  retreatUnits unitsAndRets
-- similar to above

randomProcessUnits (UnitPositions (Turn Winter _) units) ownSupplies _ =
  disbandOrBuild units ownSupplies
{- need to disband if we have too many units or build units if we have the 
   opportunity to build i.e. we have more supply centres than units and units have         
   controlled the province for at least 2 turns 
-}



-----------GET A RANDOM MOVE FOR A CURRENT UNITPOSITION-------------


getRandomMove :: [UnitPosition] -> MapDefinition -> RandomBrain RandomBotDecision
--get a list of (province,[available provinces to move to])
--get list of (unitType, provinces) (i.e. provinces where units are in, not where supply centres are)
--one question: SupplyCentreOwnership has Province, not ProvinceNode. Why?
          --or rather: why have ProvinceNode in the first place?
getRandomMove units mapDef = return . RandomMoveDecision =<< mapM (findProvinceToMoveTo mapDef) units  


findProvinceToMoveTo :: MapDefinition -> UnitPosition -> RandomBrain (UnitPosition, ProvinceNode)
findProvinceToMoveTo mapDef (UnitPosition power unitType provinceNode) = do
  let adjacencies = mapDefAdjacencies mapDef
  let provinceNodes = getValidAdjacencies unitType provinceNode adjacencies
  randomInt <- getRandomR (0,length provinceNodes - 1)
  let provinceNodeChoice = provinceNodes !! randomInt 
  return ((UnitPosition power unitType provinceNode), provinceNodeChoice)
  --will return a list of available provinces that we can move to (depending if we're army or fleet)
  
--TO DO: need to figure out the available adjacencies that we can go to (i.e. ones where other powers are occupying)
--SO ONE VERSION: what we need to do is find all the provinces occupied by other
--                powers so we don't go there
--HOWEVER       : can make it easier by not caring if other provinces are occupied
--                and that way can just find adjacencies for our provinces and 
--                and choose one to move in randomly 

getValidAdjacencies :: UnitType -> ProvinceNode -> [Adjacency] -> [ProvinceNode]
--not on a coast, so either inland or on sea
getValidAdjacencies unitType (ProvNode province) adjacencies = 
  getProvinceNodesForUnitType (getOurAdjacency adjacencies province) unitType

--on a coast, so it's a fleet and therefore can move to either sea or land
getValidAdjacencies _ (ProvCoastNode province coast) adjacencies = 
  getProvinceNodesForCoastalFleet (getOurAdjacency adjacencies province) coast

--------------------------For units not on coasts-------------------------
getProvinceNodesForUnitType :: Adjacency -> UnitType -> [ProvinceNode]
getProvinceNodesForUnitType (Adjacency _ unitToProvs) unitType = 
  getProvinceNodesFromUnitToProvList unitToProvs unitType

getProvinceNodesFromUnitToProvList :: [UnitToProv] -> UnitType -> [ProvinceNode]
getProvinceNodesFromUnitToProvList unitToProvs unitType =  
  concat $ map extractProvinceNodes $ filter (getProvinceNodesFromUnitToProv unitType) unitToProvs

getProvinceNodesFromUnitToProv :: UnitType -> UnitToProv -> Bool
getProvinceNodesFromUnitToProv ourUnitType (UnitToProv unitType _)  = 
  unitType == ourUnitType
--------------------------------------------------------------------------


-----------------------For units (fleets) on coasts-----------------------
getProvinceNodesForCoastalFleet :: Adjacency -> Coast -> [ProvinceNode]
getProvinceNodesForCoastalFleet(Adjacency _ unitToProvs) coast = 
  getProvinceNodesFromUnitToProvListCoastal unitToProvs coast

getProvinceNodesFromUnitToProvListCoastal :: [UnitToProv] -> Coast -> [ProvinceNode]
getProvinceNodesFromUnitToProvListCoastal unitToProvs coast =  
  concat $ map extractProvinceNodes $ filter (getProvinceNodesFromUnitToProvCoastal coast) unitToProvs

getProvinceNodesFromUnitToProvCoastal :: Coast -> UnitToProv -> Bool
getProvinceNodesFromUnitToProvCoastal ourCoast (CoastalFleetToProv coast _)  = 
  coast == ourCoast
--------------------------------------------------------------------------

extractProvinceNodes :: UnitToProv -> [ProvinceNode]
extractProvinceNodes (UnitToProv _ provinceNodes) = provinceNodes
extractProvinceNodes (CoastalFleetToProv _ provinceNodes) = provinceNodes

getOurAdjacency :: [Adjacency] -> Province -> Adjacency
getOurAdjacency adjacencies ourProvince = 
  head $ [(Adjacency province unitToProv) | (Adjacency province unitToProv) <- adjacencies, province == ourProvince]

--------------------------------------------------------------------------------



-------RETREAT UNITS-------

retreatUnits :: [(UnitPosition, [ProvinceNode])] -> RandomBrain RandomBotDecision
retreatUnits unitsAndRetreats = do 
  let units = [unit| (unit, _) <- unitsAndRetreats]
  myPower <- getPower
  return $ DisbandDecision $ filter (isMyPower myPower) units


-------DISBAND OR BUILD--------

disbandOrBuild :: [UnitPosition] ->  [Province] -> RandomBrain RandomBotDecision
disbandOrBuild units supplyCentres 
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





