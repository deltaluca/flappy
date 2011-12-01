{- |
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
import Diplomacy.AI.SkelBot.DipBot

import Diplomacy.Common.DipMessage
import Diplomacy.Common.Data

import Data.Map hiding (map, filter)
import Data.List
import System.Random
import Control.Monad.IO.Class
import Control.Monad.Random
import Control.Monad.Trans
import Control.Monad

data RandomBotDecision = RandomMoveDecision [(UnitPosition,ProvinceNode)]
                     | DisbandDecision [UnitPosition]
                     | RemoveDecision [UnitPosition]
                     | BuildDecision [UnitPosition] 
                     | WaiveDecision Power

type RandomBotHistory = ()

instance Decision RandomBotDecision where
  diplomise (RandomMoveDecision units) = [SubmitOrder Nothing (map randomOrderForUnit units)]
  diplomise (DisbandDecision units) = [SubmitOrder Nothing (map disbandOrderForUnit units)]
  diplomise (RemoveDecision units) = [SubmitOrder Nothing (map removeOrderForUnit units)]
  diplomise (WaiveDecision power) = [SubmitOrder Nothing [OrderBuild (Waive power)]]


-- |randomOrderForUnit produces a random order for each unit
randomOrderForUnit :: (UnitPosition,ProvinceNode) -> Order
randomOrderForUnit (unit,provinceNode) = OrderMovement (Move unit provinceNode)

-- |disbandOrderForUnit produces an order to disband the unit
disbandOrderForUnit :: UnitPosition -> Order
disbandOrderForUnit unit = OrderRetreat (Disband unit)

--produces an order to disband the unit during winter phase 
removeOrderForUnit :: UnitPosition -> Order
removeOrderForUnit unit = OrderBuild (Remove unit)

-- |getPower gets what power we are playing as
getPower :: RandomBrain Power
getPower = asksGameInfo gameInfoPower

-- |getMapDef gets the map definition (layout of the map)
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

-- |randomBrain is the brain that gets run
randomBrain :: RandomBrain ()
randomBrain = do
  curMapState <- asksGameState gameStateMap --returns our mapState
  mapDef <- getMapDef --get map definition
  let unitPoss = unitPositions curMapState
  let supplyOwns = supplyOwnerships curMapState
  ownSupplies <- getOwnSupplies supplyOwns --gets the supply centres we currently own
  myDecision <- randomProcessUnits unitPoss ownSupplies mapDef
  putDecision $ Just myDecision --puts the decision back into the brain

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

getOwnSupplies :: SupplyCOwnerships -> RandomBrain [Province]
getOwnSupplies (SupplyCOwnerships supplies) = do
  myPower <- getPower
  return . head $ [provinces | (power, provinces) <- toList supplies, myPower == power]

-- |randomProcessUnits will handle the different seasons during the year and produce the right decision accordingly
randomProcessUnits :: UnitPositions -> [Province] -> MapDefinition -> RandomBrain RandomBotDecision
-- ^[province] here is the provinces where we own supply centres+
randomProcessUnits (UnitPositions (Turn Spring _) units) _ mapDef = do
  myPower <- getPower    
  getRandomMove (filter (isMyPower myPower) units) mapDef

randomProcessUnits (UnitPositions (Turn Fall _) units) _ mapDef = do
  myPower <- getPower    
  getRandomMove (filter (isMyPower myPower) units) mapDef

randomProcessUnits (UnitPositionsRet (Turn Summer _) unitsAndRets) _ _ =
  retreatUnits unitsAndRets
{- |when dislodged, we need to retreat our units that need retreating
   unitsAndRets is a list of units that need to be retreating and
   each unit will have a corresponding list of provinces it can retreat to
   in our randombot case we just disband.
-}

randomProcessUnits (UnitPositionsRet (Turn Autumn _) unitsAndRets) _ _ =
  retreatUnits unitsAndRets
-- similar to above

randomProcessUnits (UnitPositions (Turn Winter _) units) ownSupplies mapDef = do
  myPower <- getPower
  removeOrBuild (filter (isMyPower myPower) units) ownSupplies mapDef
{- |need to disband if we have too many units or build units if we have the 
   opportunity to build i.e. we have more supply centres than units and units have         
   controlled the province for at least 2 turns 
-}



-----------GET A RANDOM MOVE FOR A CURRENT UNITPOSITION-------------

-- |getRandomMove will get random moves for every unit (moving to adjacent provinces)
getRandomMove :: [UnitPosition] -> MapDefinition -> RandomBrain RandomBotDecision

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

getValidAdjacencies :: UnitType -> ProvinceNode -> Adjacencies -> [ProvinceNode]
--not on a coast, so either inland or on sea
getValidAdjacencies unitType (ProvNode province) (Adjacencies adjacencies) = 
  getProvinceNodesForUnitType (getOurAdjacency (toList adjacencies) province) unitType

--on a coast, so it's a fleet and therefore can move to either sea or land
getValidAdjacencies _ (ProvCoastNode province coast) (Adjacencies adjacencies) = 
  getProvinceNodesForCoastalFleet (getOurAdjacency (toList adjacencies) province) coast

--------------------------For units not on coasts-------------------------
getProvinceNodesForUnitType :: (Province, [UnitToProv]) -> UnitType -> [ProvinceNode]
getProvinceNodesForUnitType (_, unitToProvs) unitType = 
  getProvinceNodesFromUnitToProvList unitToProvs unitType

getProvinceNodesFromUnitToProvList :: [UnitToProv] -> UnitType -> [ProvinceNode]
getProvinceNodesFromUnitToProvList unitToProvs unitType =  
  concat $ map extractProvinceNodes $ filter (getProvinceNodesFromUnitToProv unitType) unitToProvs

getProvinceNodesFromUnitToProv :: UnitType -> UnitToProv -> Bool
getProvinceNodesFromUnitToProv ourUnitType (UnitToProv unitType _)  = 
  unitType == ourUnitType
--------------------------------------------------------------------------


-----------------------For units (fleets) on coasts-----------------------
getProvinceNodesForCoastalFleet :: (Province, [UnitToProv]) -> Coast -> [ProvinceNode]
getProvinceNodesForCoastalFleet(_, unitToProvs) coast = 
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

getOurAdjacency :: [(Province, UnitToProv)] -> Province -> (Province, [UnitToProv])
getOurAdjacency adjacencies ourProvince = 
  head $ [(province, unitToProv) | (province, unitToProv) <- adjacencies, province == ourProvince]

--------------------------------------------------------------------------------



-------RETREAT UNITS-------

retreatUnits :: [(UnitPosition, [ProvinceNode])] -> RandomBrain RandomBotDecision
retreatUnits unitsAndRetreats = do 
  let units = [unit| (unit, _) <- unitsAndRetreats]
  myPower <- getPower
  return $ DisbandDecision $ filter (isMyPower myPower) units


-------DISBAND OR BUILD--------

-- TO DO: NEED TO WORK OUT HOW TO BUILD SUPPLY CENTRES, I.e. CHECK OUR LIST OF PROVINCES 
--        THAT WE HAVE SUPPLY CENTRES IN AND CHECK IF ANY OF THOSE PROVINCES ARE IN OUR
--        HOME COUNTRY. 
--        THEN CHECK IF WE HAVE UNITS IN THOSE HOME PROVINCES AND IF NOT, WE CAN SUBMIT
--        A BUILD ORDER TO BUILD A NEW UNIT ON THAT PROVINCE

removeOrBuild :: [UnitPosition] ->  [Province] -> MapDefinition -> RandomBrain RandomBotDecision
removeOrBuild units ownSupplyCentres mapDef
  | difference > 0  = return $ DisbandDecision (take difference units)
  | difference == 0 = do
                         myPower <- getPower
                         return $ WaiveDecision myPower
  | otherwise       = do --check if we can build
                         myPower <- getPower
                         let provincesDef = mapDefProvinces mapDef
                         let homeCentres = getHomeSupplyCentres provincesDef myPower
                         let homeCentresOwned = intersect ownSupplyCentres homeCentres
                         return $ BuildDecision $ getCentresToBuildAt units homeCentresOwned
  where 
    difference = (length units) - (length supplyCentres)  
     {- if we have less units than supply centres and we have vacant supply centres in our home country, then we can build on these home supply centres -}
 

-- | getHomeSupplyCentre returns a list of provinces that are defined to be in our home country (so that we can build units in them)
getHomeSupplyCentres :: Provinces -> Power -> [Province]
getHomeSupplyCentres (Provinces supplycentres _) power = 
  findOurSupplyCentre supplycentres power

findOurSupplyCentre :: [SupplyCentreOwnership] -> Power -> [Province]
findOurSupplyCentre supplyCentres power = head $ filter (isMyPowerSupplyCentre power) supplyCentres

-- |getCentresToBuildAt returns a list of provinces in our home country that we can build in, i.e. home controlled provinces which have no units in them currently
getCentresToBuildAt :: [UnitPosition] -> [Province] -> [Province]
getCentresToBuildAt units homeProvincesControlled = 
  map extractProvinceFromNode [provinceNode | (UnitPosition _ _ provinceNode) <- units]
  
extractProvinceFromNode :: ProvinceNode -> Province
extractProvinceFromNode (ProvNode province) = province
extractProvinceFromNode (ProvCoastNode province _) = province

-- | isMyPower checks if this UnitPosition is ours (if it contains our power number)
isMyPower :: Power -> UnitPosition -> Bool
isMyPower myPower (UnitPosition power _ _) = power == myPower 

-- | 
isMyPowerSupplyCentre :: Power -> SupplyCentreOwnerShip -> Bool
isMyPowerSupplyCentre myPower (SupplyCentre power provinceList) = myPower == power





