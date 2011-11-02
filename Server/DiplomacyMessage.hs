{-# LANGUAGE EmptyDataDecls, FlexibleInstances, MultiParamTypeClasses #-}
module DiplomacyMessage where

import DiplomacyToken as Tok
import DiplomacyData as Dat

import Text.Parsec
import Data.Maybe
import Control.Monad.Identity

  -- DESC (SENDING PARTY)
data DipMessage -- first message (CLIENT)
               = Name { startName :: String
                      , startVersion :: String }

                 -- client is observer (CLIENT)
               | Observer

                 -- client wants to rejoin (CLIENT)
               | Rejoin { rejoinPower :: Power
                        , rejoinPasscode :: Int }

                 -- map name (SERVER)
               | MapName { mapName :: String }

                 -- requesting map name (CLIENT)
               | MapNameReq

                 -- definition of the map (SERVER)
               | MapDef { mapDefPowers :: [Power]
                        , mapDefProvinces :: Provinces
                        , mapDefAdjacencies :: [Adjacency] }

                 -- requesting the definition of the map (CLIENT)
               | MapDefReq

                 -- accept message (SERVER, CLIENT)
               | Accept DipMessage

                 -- reject message (SERVER, CLIENT)
               | Reject DipMessage

                 -- cancel message (CLIENT)
               | Cancel DipMessage

                 -- game is starting (SERVER)
               | Start { startPower :: Power
                       , startPasscode :: Int
                       , startLevel :: Int
                       , startVariantOpts :: [VariantOption] }

                 -- requesting whether game started (CLIENT) or replying yes (SERVER)
               | StartPing

                 -- current position (SERVER)
               | CurrentPosition [SupplyCentre]

                 -- current position request (CLIENT)
               | CurrentPositionReq

                 -- current position of units (SERVER)
               | CurrentUnitPosition Turn [UnitPosition] (Maybe [ProvinceNode])

                 -- current position of units request (CLIENT)
               | CurrentUnitPositionReq

                 -- history requested (CLIENT)
               | HistoryReq Turn

                 -- submitting orders (CLIENT)
               | SubmitOrder (Maybe Turn) [Order]
                 
                 -- acknowledge order (SERVER)
               | AckOrder Order OrderNote
               
                 -- missing movement orders (SERVER)
               | MissingMovement [UnitPosition]
                 
                 -- missing retreat orders (SERVER)
               | MissingRetreat [(UnitPosition, [ProvinceNode])]
               
                 -- missing build orders (SERVER)
               | MissingBuild Int
               deriving (Show)

data Order = OrderMovement OrderMovement
           | OrderRetreat OrderRetreat
           | OrderBuild OrderBuild
           deriving (Show)

data OrderNote = MovementOK
               | NotAdjacent
               | NoSuchProvince
               | NoSuchUnit
               | NotAtSea
               | NoSuchFleet
               | NoSuchArmy
               | NotYourUnit
               | NoRetreatNeeded
               | InvalidRetreatSpace
               | NotYourSC
               | NotEmptySC
               | NotHomeSC
               | NotASC
               | InvalidBuildLocation
               | NoMoreBuildAllowed
               | NoMoreRemovalAllowed
               | NotCurrentSeason
               deriving (Show)

data OrderMovement = Hold UnitPosition
                   | Move UnitPosition ProvinceNode
                   | SupportHold UnitPosition UnitPosition
                   | SupportMove UnitPosition UnitPosition Province
                   | Convoy UnitPosition UnitPosition ProvinceNode
                   | MoveConvoy UnitPosition ProvinceNode [Province]
                   deriving (Show)

data OrderRetreat = Retreat UnitPosition ProvinceNode
                  | Disband UnitPosition
                  deriving (Show)

data OrderBuild = Build UnitPosition
                | Remove UnitPosition
                | Waive Power
                deriving (Show)

data Provinces = Provinces [SupplyCentre] [Province]
               deriving (Show)

data Turn = Turn Phase Int
            deriving (Show)

data UnitPosition = UnitPosition Power UnitType ProvinceNode
                  deriving (Show)

data VariantOption = Level Int
                   | TimeMovement Int
                   | TimeRetreat Int
                   | TimeBuild Int
                   | DeadlineStop
                   | AnyOrderAccepted
                   deriving (Show)

data SupplyCentre = SupplyCentre Power [Province]
                    deriving (Show)

data Adjacency = Adjacency Province [UnitToProv]
             deriving (Show)

data UnitToProv = UnitToProv UnitType [ProvinceNode]
                | CoastalFleetToProv Coast [ProvinceNode]
                deriving (Show)

data ProvinceNode = ProvNode Province | ProvCoastNode Province Coast
                  deriving (Show)

type DipParser = Parsec [DipToken] ()

parseDipMessage :: String -> [DipToken] -> Either ParseError DipMessage
parseDipMessage = parse pMsg

mayEq a b = if a == b then Just a else Nothing

tok f = getPosition >>= \p -> token show (const p) f

tok1 a = tok (mayEq a)

paren a = do
  tok1 Bra
  r <- a
  tok1 Ket
  return r

pStr :: DipParser String
pStr = many pChr

pChr :: DipParser Char
pChr = tok (\t -> case t of {Character c -> Just c ; _ -> Nothing})

pInt :: DipParser Int
pInt = tok (\t -> case t of {DipInt i -> Just i ; _ -> Nothing})

pMsg :: DipParser DipMessage
pMsg = choice [ pAccept, pReject
              , pNme, pObs
              , pMap, pMdf
              , pHlo
              , pSco, pNow, pHistoryReq
              ]

pAccept = return . Accept =<< (tok1 (DipCmd YES) >> paren pMsg)
pReject = return . Reject =<< (tok1 (DipCmd REJ) >> paren pMsg)
pCancel = return . Cancel =<< (tok1 (DipCmd NOT) >> paren pMsg)

pNme = do
  tok1 (DipCmd NME)
  startName <- paren pStr
  startVersion <- paren pStr
  return (Name startName startVersion)

pMap = tok1 (DipCmd MAP) >> choice [pMapName, pMapNameReq]

pObs = tok1 (DipCmd OBS) >> return Observer

pIam = do
  tok1 (DipCmd IAM)
  power <- paren pPower
  passcode <- paren pInt
  return (Rejoin power passcode)

pMapName = return . MapName =<< paren pStr

pMapNameReq = return MapNameReq

pMdf = tok1 (DipCmd MDF) >> choice [pMapDef, pMapDefReq]

pMapDef = do
  powers <- paren (many pPower)
  provinces <- paren pProvinces
  adjacencies <- paren (many (paren pAdjacency))
  return (MapDef powers provinces adjacencies)

pMapDefReq = return MapDefReq

pPower = tok (\t -> case t of { DipPow (Pow p) -> Just (Power p)
                              ; DipParam UNO -> Just Neutral
                              ; _ -> Nothing})

pProvinces = do
  supplyCentres <- paren (many pSupplyCentre)
  nonSupplyCentres <- paren (many pProvince)
  return (Provinces supplyCentres nonSupplyCentres)

pAdjacency = do
  province <- pProvince
  unitToProvs <- paren (many (paren pUnitToProv))
  return (Adjacency province unitToProvs)

pUnitToProv = do
  unitType <- pUnitType
  provNodes <- many pProvinceNode
  return (UnitToProv unitType provNodes)

pCoastalFleetToProv = do
  coast <- paren (tok1 (DipUnitType Fleet) >> pCoast)
  provNodes <- many pProvinceNode
  return (CoastalFleetToProv coast provNodes)

pUnitType = tok (\t -> case t of {DipUnitType typ -> Just typ ; _ -> Nothing})

pCoast = tok (\t -> case t of {DipCoast c -> Just c ; _ -> Nothing})

pProvinceNode = (return . ProvNode =<< pProvince) <|>
                (paren $ do
                    prov <- pProvince
                    c <- pCoast
                    return (ProvCoastNode prov c))

pSupplyCentre = do
  pow <- pPower
  centres <- many pProvince
  return (SupplyCentre pow centres)

pProvince = tok (\t -> case t of {(DipProv p) -> Just p ; _ -> Nothing})

pHlo = tok1 (DipCmd HLO) >> choice [pStart, pStartPing]

pStart = do
  pow <- paren pPower
  passCode <- paren pInt
  (level, variantOpts) <- paren pVariant
  return (Start pow passCode level variantOpts)

pStartPing = return StartPing

pVariant = do
  options <- many pVariantOpt
  let (lvls, others) = splitWith (\v -> case v of {Level _ -> True ; _ -> False}) options
  case lvls of
    [] -> parserFail "No LVL option specified in HLO message"
    (Level lvl) : _ -> return (lvl, others)

pVariantOpt = choice [ return . Level         =<< (tok1 (DipParam LVL) >> pInt)
                     , return . TimeMovement  =<< (tok1 (DipParam MTL) >> pInt)
                     , return . TimeRetreat   =<< (tok1 (DipParam RTL) >> pInt)
                     , return . TimeBuild     =<< (tok1 (DipParam BTL) >> pInt)
                     , return DeadlineStop     << tok1 (DipParam DSD)
                     , return AnyOrderAccepted << tok1 (DipParam AOA)
                     ]

pSco = tok1 (DipCmd SCO) >> choice [pCurrentPos, pCurrentPosReq]

pCurrentPos = return . CurrentPosition =<< many (paren pSupplyCentre)
pCurrentPosReq = return CurrentPositionReq

pPhase = tok (\t -> case t of {DipPhase p -> Just p ; _ -> Nothing})

pTurn = do
  phase <- pPhase
  year <- pInt
  return (Turn phase year)

pNow = tok1 (DipCmd NOW) >> choice [pCurrentUnitPos, pCurrentUnitPosReq]

pCurrentUnitPos = do
  turn <- paren pTurn
  unitPoss <- many (paren pUnitPosition)
  retreats <- (tok1 (DipParam MRT) >> (paren . many . paren) pProvinceNode
               >>= return . Just)
              <|> return Nothing
  return (CurrentUnitPosition turn unitPoss retreats)

pCurrentUnitPosReq = return CurrentUnitPositionReq

pUnitPosition = do
  pow <- pPower
  typ <- pUnitType
  provNode <- pProvinceNode
  return (UnitPosition pow typ provNode)

pHistoryReq = return . HistoryReq =<< (tok1 (DipCmd HST) >> paren pTurn)

splitWith b x = (filter b x, filter (not . b) x)

pSub = do
  turn <- (tok1 (DipCmd SUB) >> paren pTurn >>= return . Just) <|> return Nothing
  orders <- many (paren pOrderOrWaive)
  return (SubmitOrder turn orders)

pOrderOrWaive :: DipParser Order
pOrderOrWaive = pOrder <|> do
  tok1 (DipOrder WVE)
  power <- pPower
  return (OrderBuild (Waive power))

pOrder = do
  unit <- paren (pUnitPosition)
  choice . map ($ unit) $ [ pHld, pMto, pSup, pCvy, pCto -- move
                          , pRto, pDsb                   -- retreat
                          , pBld, pRem]                  -- build

pHld u = do
  tok1 (DipOrder HLD)
  return . OrderMovement . Hold $ u


pMto u = return . OrderMovement . Move u =<< (tok1 (DipOrder MTO) >> pProvinceNode)


pSup u1 = do
  tok1 (DipOrder SUP)
  u2 <- paren pUnitPosition
  pSupMove u1 u2 <|> pSupHold u1 u2

pSupMove u1 u2 = do
  tok1 (DipOrder MTO)
  return . OrderMovement . SupportMove u1 u2 =<< pProvince

pSupHold u1 u2 = return . OrderMovement . SupportHold u1 $ u2

pCvy u1 = do
  tok1 (DipOrder CVY)
  u2 <- paren pUnitPosition
  tok1 (DipOrder CTO)
  return . OrderMovement . Convoy u1 u2 =<< pProvinceNode

pCto u = do
  tok1 (DipOrder CTO)
  prov <- pProvinceNode
  tok1 (DipOrder VIA)
  return . OrderMovement . MoveConvoy u prov =<< paren (many pProvince)

pRto u = return . OrderRetreat . Retreat u =<< (tok1 (DipOrder RTO) >> pProvinceNode)

pDsb u = (return . OrderRetreat . Disband) u << tok1 (DipOrder DSB)

pBld u = (return . OrderBuild . Build) u << tok1 (DipOrder BLD)

pRem u = (return . OrderBuild . Remove) u << tok1 (DipOrder REM)

pAck = do
  order <- paren pOrder
  orderNote <- paren pOrderNote
  return (AckOrder order orderNote)

pOrderNote = tok (\t -> case t of {DipOrderNote tk -> return (f tk) ; _ -> Nothing})
  where
    f MBV = MovementOK
    f FAR = NotAdjacent
    f NSP = NoSuchProvince
    f NSU = NoSuchUnit
    f NAS = NotAtSea
    f NSF = NoSuchFleet
    f NSA = NoSuchArmy
    f NYU = NotYourUnit
    f NRN = NoRetreatNeeded
    f NVR = InvalidRetreatSpace
    f YSC = NotYourSC
    f ESC = NotEmptySC
    f HSC = NotHomeSC
    f NSC = NotASC
    f CST = InvalidBuildLocation
    f NMB = NoMoreBuildAllowed
    f NMR = NoMoreRemovalAllowed
    f NRS = NotCurrentSeason

    -- "try" used because of the freaking 2.3gajillion token lookahead
pMis = choice [ return . MissingMovement =<< (try . many . paren) pUnitPosition
              , return . MissingRetreat =<< (try . many . paren . pPair)
                (pUnitPosition, tok1 (DipParam MRT) >> paren (many pProvinceNode))
              , return . MissingBuild =<< paren pInt
              ]

pPair :: (ParsecT s u m a, ParsecT s u m b) -> ParsecT s u m (a, b)
pPair (a, b) = do
  aRes <- a
  bRes <- b
  return (a, b)

