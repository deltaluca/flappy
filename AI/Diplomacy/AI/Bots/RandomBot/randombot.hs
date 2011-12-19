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

{-
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
-}

-- |randomOrderForUnit produces a random order for each unit
randomOrderForUnit :: (UnitPosition,ProvinceNode) -> OrderMovement
randomOrderForUnit (unit,provinceNode) = (Move unit provinceNode)

-- |disbandOrderForUnit produces an order to disband the unit
disbandOrderForUnit :: UnitPosition -> OrderRetreat
disbandOrderForUnit unit = (Disband unit)

--produces an order to disband the unit during winter phase 
removeOrderForUnit :: UnitPosition -> OrderBuild
removeOrderForUnit unit = (Remove unit)

-- |getPower gets what power we are playing as
getPower :: (OrderClass o) => HoldBrain o Power
getPower = asksGameInfo gameInfoPower

-- |getMapDef gets the map definition (layout of the map)
getMapDef :: (OrderClass o) => HoldBrain o MapDefinition
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

--type RandomBrainCommT m = RandT StdGen (BrainCommT RandomBotDecision () m)
--type RandomBrain = RandT StdGen (Brain RandomBotDecision ())

type RandomBrain o = Brain o ()
type RandomBrainMoveCommT m = RandT StdGen (BrainCommT OrderMovement () m)
type RandomBrainMove = RandT StdGen (Brain OrderMovement ())
type RandomBrainRetreatCommT m = RandT StdGen (BrainCommT OrderRetreat () m)
type RandomBrainRetreat = RandT StdGen (Brain OrderRetreat ())
type RandomBrainBuildCommT m = RandT StdGen (BrainCommT OrderBuild () m)
type RandomBrainBuild = RandT StdGen (Brain OrderBuild ())


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
randomBot = DipBot { dipBotName = "FlappyRandomBot"
                     dipBotVersion = 0.1
                 -- dipBotBrainComm = randomBrainComm
                 --, dipBotProcessResults = randomProcessResult
                 , dipBotBrainMovement = randomBrainMovement
                 , dipBotBrainRetreat = randomBrainRetreat
                 , dipBotBrainBuild = randomBrainBuild
                 , dipBotProcessResults = randomProcessResults
                 , dipBotInitHistory = randomInitHistory }


randomBrainComm :: (MonadIO m) => BrainCommT RandomBotDecision () m ()
randomBrainComm = do
  stdGen <- liftIO getStdGen
  liftBrain (runBrain (liftM fst (runRandT randomBrain stdGen)))

-- |randomBrain is the brain that gets run
-- THIS PROBABLY DOESN'T NEED TO BE HERE, BUT I LEFT IT JUST IN CASE, 
randomBrain :: RandomBrain ()
randomBrain = do
  curMapState <- asksGameState gameStateMap --returns our mapState
  mapDef <- getMapDef --get map definition
  let unitPoss = unitPositions curMapState
  let supplyOwns = supplyOwnerships curMapState
  ownSupplies <- getOwnSupplies supplyOwns --gets the supply centres we currently own
  myDecision <- randomProcessUnits unitPoss ownSupplies mapDef
  putDecision $ Just myDecision --puts the decision back into the brain
--need to use putorder... but have to change everything to NOT be a decision...



randomBrainMovement :: RandomBrainMove ()
  curMapState <- asksGameState gameStateMap --returns our mapState
  mapDef <- getMapDef --get map definition
  let unitPoss = unitPositions curMapState
  unitMovements <- randomUnitsMovement unitPoss mapDef
  putOrders $ Just (map randomOrderForUnit unitMovements)
--putOrders isn't really going to work anymore if we use 

randomBrainRetreat :: RandomBrainRetreat ()
  curMapState <- asksGameState gameStateMap --returns our mapState
  mapDef <- getMapDef --get map definition
  let unitPoss = unitPositions curMapState
  unitRetreats <- randomUnitsRetreat unitPoss
  putOrders $ Just (map disbandOrderForUnit unitRetreats)

randomBrainBuild :: RandomBrainBuild ()
  curMapState <- asksGameState gameStateMap --returns our mapState
  mapDef <- getMapDef --get map definition
  let unitPoss = unitPositions curMapState
  let supplyOwns = supplyOwnerships curMapState
  ownSupplies <- getOwnSupplies supplyOwns --gets the supply centres we currently own
  unitBuilds <- randomUnitsBuild unitPoss ownSupplise mapDef
  putOrders --can return 3 things, what do i do?


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


--return a list of [(UnitPosition,ProvinceNode)]
randomUnitsMovement :: UnitPositions -> MapDefinition -> RandomBrainMove [(UnitPosition,ProvinceNode)]
randomUnitsMovement (UnitPositions (Turn Spring _) units) mapDef = do
  myPower <- getPower    
  chooseRandomOrders (filter (isMyPower myPower) units) mapDef []

randomUnitsMovement (UnitPositions (Turn Fall _) units) mapDef = do
  myPower <- getPower    
  chooseRandomOrders (filter (isMyPower myPower) units) mapDef []



--return a list of [(UnitPosition,ProvinceNode)]
randomUnitsRetreat :: UnitPositions -> RandomBrainRetreat [UnitPosition]
randomUnitsRetreat (UnitPositionsRet (Turn Summer _) unitsAndRets) =
  retreatUnits unitsAndRets
{- |when dislodged, we need to retreat our units that need retreating
   unitsAndRets is a list of units that need to be retreating and
   each unit will have a corresponding list of provinces it can retreat to
   in our randombot case we just disband.
-}

randomUnitsRetreat (UnitPositionsRet (Turn Autumn _) unitsAndRets) =
  retreatUnits unitsAndRets
-- similar to above



randomUnitsBuild :: UnitPositions -> [Province] -> MapDefinition -> RandomBrainBuild RandomBotDecision
randomUnitsBuild (UnitPositions (Turn Winter _) units) ownSupplies mapDef = do
  myPower <- getPower
  removeOrBuild (filter (isMyPower myPower) units) ownSupplies mapDef
{- |need to disband if we have too many units or build units if we have the 
   opportunity to build i.e. we have more supply centres than units and units have         
   controlled the province for at least 2 turns 
-}



-----------GET A RANDOM MOVE FOR A CURRENT UNITPOSITION-------------

--foldl :: (b->a->b) -> b -> [a] -> b
--i.e. ([OrderMovement] -> UnitPosition -> [OrderMovement]) -> [OrderMovement] -> [UnitPosition] -> [OrderMovement]

--e.g foldl (\orders unit -> (someFunction unit) : orders) inputOrderList inputUnitList

chooseRandomOrders :: [UnitPosition] -> MapDefinition -> [OrderMovement] -> RandomBrainMove [OrderMovement]
chooseRandomOrders [] _ orderMovements = orderMovements
chooseRandomOrders (unit:xs) mapDef orderMovements = 
  chooseRandomOrders xs mapDef ((produceRandomMovement unit mapDef orderMovements):orderMovements)

--generate a list of all possible OrderMovements for each unitposition and choose random one

produceRandomMovement :: UnitPosition -> MapDefinition -> [OrderMovement] -> RandomBrainMove OrderMovement
produceRandomMovement unit mapDef currentOrders = do
  orders <- findAllPossibleMoves unit mapDef currentOrders
  randomInt <- getRandomR (0, length orders - 1)
  return $ orders !! randomInt
--takes the concat'd list from below and picks a random one


findAllPossibleMoves :: UnitPosition -> MapDefinition -> [OrderMovement] -> RandomBrainMove [OrderMovement]
findAllPossibleMoves (UnitPosition power unitType provinceNode) mapDef currentOrders = do
  let adjacencies = mapDefAdjacencies mapDef
  let adjacentProvinces = getValidAdjacencies unitType provinceNode adjacencies
  return $ (produceMovementOrders (UnitPosition power unitType provinceNode) adjacentProvinces) ++
  (produceSupportOrders (UnitPosition power unitType provinceNode) currentOrders adjacentProvinces)
--produces all possible movement orders and all possible support orders and concats

produceMovementOrders :: UnitPosition -> [ProvinceNode] -> [OrderMovement]
produceMovementOrders ourUnit ourAdjacencies = map (Move ourUnit) ourAdjacencies

produceSupportOrders :: UnitPosition -> [OrderMovement] -> [ProvinceNode] -> [OrderMovement]
produceSupportOrders ourUnit orderMovements ourAdjacencies = 
map (produceSupportMove ourUnit) [(unit,province) | (Move unit province) <- orderMovements, elem province ourAdjacencies] 
-- find common provinces, i.e. provinces that are adjacent to us that are being attacked by friendly units, meaning we can support them!

produceSupportMove :: UnitPosition -> (UnitPosition,ProvinceNode) -> OrderMovement
produceSupportMove ourUnit (supportUnit, provinceNode) = SupportMove ourUnit (extractProvinceFromNode provinceNode)

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

-----------some useful helper functions-------------
extractProvinceNodes :: UnitToProv -> [ProvinceNode]
extractProvinceNodes (UnitToProv _ provinceNodes) = provinceNodes
extractProvinceNodes (CoastalFleetToProv _ provinceNodes) = provinceNodes

getOurAdjacency :: [(Province, UnitToProv)] -> Province -> (Province, [UnitToProv])
getOurAdjacency adjacencies ourProvince = 
  head $ [(province, unitToProv) | (province, unitToProv) <- adjacencies, province == ourProvince]

--------------------------------------------------------------------------------



-------RETREAT UNITS-------

retreatUnits :: [(UnitPosition, [ProvinceNode])] -> RandomBrainRetreat [UnitPosition]
retreatUnits unitsAndRetreats = do 
  let units = [unit| (unit, _) <- unitsAndRetreats]
  myPower <- getPower
  return $ filter (isMyPower myPower) units


-------DISBAND OR BUILD--------

-- TO DO: NEED TO WORK OUT HOW TO BUILD SUPPLY CENTRES, I.e. CHECK OUR LIST OF PROVINCES 
--        THAT WE HAVE SUPPLY CENTRES IN AND CHECK IF ANY OF THOSE PROVINCES ARE IN OUR
--        HOME COUNTRY. 
--        THEN CHECK IF WE HAVE UNITS IN THOSE HOME PROVINCES AND IF NOT, WE CAN SUBMIT
--        A BUILD ORDER TO BUILD A NEW UNIT ON THAT PROVINCE

removeOrBuild :: [UnitPosition] ->  [Province] -> MapDefinition -> RandomBrainBuild RandomBotDecision
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

-- | isMyPower checks if this UnitPosition is ours (if it contains our power number)
isMyPower :: Power -> UnitPosition -> Bool
isMyPower myPower (UnitPosition power _ _) = power == myPower 

-- | helper function for findOurSupplyCentre
isMyPowerSupplyCentre :: Power -> SupplyCentreOwnerShip -> Bool
isMyPowerSupplyCentre myPower (SupplyCentre power provinceList) = myPower == power


-- |Just extract the province from the provinceNode, don't care about anything else
extractProvinceFromNode :: ProvinceNode -> Province
extractProvinceFromNode (ProvNode province) = province
extractProvinceFromNode (ProvCoastNode province _) = province

