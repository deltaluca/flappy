{-# LANGUAGE EmptyDataDecls, FlexibleInstances, MultiParamTypeClasses #-}
module DiplomacyMessage where

import DiplomacyToken as Tok
import DiplomacyData as Dat
import DiplomacyError

import Text.Parsec
import Data.Either
import Data.Maybe
import Control.Monad.Identity
import Control.Monad.Error
import Control.Monad.Reader

  -- Things to look out for:
  -- ambiguity: StartPing and MissingReq
  -- Cancel (StartProcessing) means dont process until deadline (ignore?)
  
  -- DESC (SENDING PARTY)
data DipMessage 
               = Name { startName :: String
                      , startVersion :: String } -- ^first message (CLIENT)
               | Observer -- ^client is observer (CLIENT)
                 
               | Rejoin { rejoinPower :: Power
                        , rejoinPasscode :: Int } -- ^client wants to rejoin (CLIENT)
                 
               | MapName { mapName :: String } -- ^map name (SERVER)
                 
               | MapNameReq -- ^requesting map name (CLIENT)
               
               | MapDef { mapDefPowers :: [Power]
                        , mapDefProvinces :: Provinces
                        , mapDefAdjacencies :: [Adjacency] } -- ^definition of the map (SERVER)

               | MapDefReq -- ^requesting the definition of the map (CLIENT)
                 
               | Accept DipMessage -- ^accept message (SERVER, CLIENT)
                 
               | Reject DipMessage -- ^reject message (SERVER, CLIENT)
                 
               | Cancel DipMessage -- ^cancel message (CLIENT)

               | Start { startPower :: Power
                       , startPasscode :: Int
                       , startLevel :: Int
                       , startVariantOpts :: [VariantOption] } -- ^game is starting
                 
               | StartPing -- ^requesting whether game started (CLIENT) or replying yes (SERVER)

               | CurrentPosition [SupplyCentre] -- ^current position (SERVER)
                 
               | CurrentPositionReq -- ^current position request (CLIENT)
                 
               | CurrentUnitPosition Turn [UnitPosition] (Maybe [ProvinceNode]) 
                 -- ^current position of units (SERVER)

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
                 
                 -- missing request (CLIENT) or replying 'no more missing request' (SERVER)
               | MissingReq
                 
                 -- start processing orders (CLIENT) (Missing... follows)
               | StartProcessing
               
                 -- result of an order after turn is processed (SERVER)
               | OrderResult Turn Order Result
                 
                 -- save game (SERVER)
               | SaveGame String
               
                 -- load game (SERVER)
               | LoadGame String
               
                 -- tell client to exit (SERVER)
               | ExitClient

                 -- time in seconds until next deadline (SERVER)
               | TimeUntilDeadline Int

                 -- throw a Diplomacy Error
               | DipError DipError

                 -- admin message sent from client to server
               | AdminMessage { playerName :: String
                              , adminMessage :: String }

                 -- game has ended due to a solo by specified power
               | SoloWinGame { soloPower :: Power }

                 -- command sent from client to server to indicate a draw
               | DrawGame 

         {-        -- full statistics at the end of the game
               | EndGameStats Turn [PlayerStat] -}

               deriving (Show)

{-data PlayerStat = PlayerStat Power String String Int (Maybe Int)
                deriving (Show)-}

data Order = OrderMovement OrderMovement
           | OrderRetreat OrderRetreat
           | OrderBuild OrderBuild
           deriving (Show)

data Result = Result (Maybe ResultNormal) (Maybe ResultRetreat)
            deriving (Show)
                     
data ResultNormal = Success
                  | MoveBounced
                  | SupportCut
                  | DisbandedConvoy
                  | NoSuchOrder
                  deriving (Show)
                    
data ResultRetreat = ResultRetreat
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

-- DipParser is a Reader (for the press level) wrapped in Parsec
type DipParser = ParsecT [DipToken] () (Reader Int)

parseDipMessage :: Monad m => Int -> [DipToken] -> ErrorT DipError m DipMessage
parseDipMessage = parseDip pMsg

parseDip :: Monad m => DipParser a -> Int -> [DipToken] -> ErrorT DipError m a
parseDip parsr lvl toks = 
  liftEither . return . mapEitherLeft (SyntaxError . show) . runReader (runParserT parsr () "Whatevs" toks) $ lvl


liftEither :: (Error e, Monad m) => m (Either e a) -> ErrorT e m a
liftEither a = lift a >>= either throwError return

mapEitherLeft :: (a -> b) -> (Either a c -> Either b c)
mapEitherLeft f = either (Left . f) (Right . id)

infixr 4 <<
(<<) :: Monad m => m a -> m b -> m a
a << b = b >>= (\_ -> a)

mayEq a b = if a == b then Just a else Nothing

tok f = getPosition >>= \p -> tokenPrim show (const . const . const $ p) f

tok1 a = tok (mayEq a)

paren a = do
  tok1 Bra <?> "\"(\" expected"
  r <- a
  tok1 Ket <?> "\")\" expected"
  return r

data Something = Sg {value :: Int}

level :: Int -> DipParser a -> DipParser a
level l p = do
  lvl <- ask
  if lvl < l
    then do
    rest <- many (tok Just)
    parserFail $ "Level " ++ show l ++ " needed to parse " ++ show rest ++ ", I only have level " ++ show lvl
    else p

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
              , pSub, pMis
              , pGof
              , pSve, pLod
              , pOff
              , pTme
              , pError
              , pAdm
              , pSlo
              , pDrw
              --, pSmr
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

pMaybe :: DipParser a -> DipParser (Maybe a)
pMaybe a = (try a >>= return . Just) <|> return Nothing

pSub = do
  turn <- (tok1 (DipCmd SUB) >> pMaybe (paren pTurn))
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
  tok1 (DipCmd THX)
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
pMis = tok1 (DipCmd MIS) >>
       choice [ return . MissingMovement =<< (try . many . paren) pUnitPosition
              , return . MissingRetreat =<< (try . many . paren . pPair)
                (pUnitPosition, tok1 (DipParam MRT) >> paren (many pProvinceNode))
              , return . MissingBuild =<< paren pInt
              , return MissingReq
              ]

pPair :: (ParsecT s u m a, ParsecT s u m b) -> ParsecT s u m (a, b)
pPair (a, b) = do
  aRes <- a
  bRes <- b
  return (aRes, bRes)

pGof = return StartProcessing << tok1 (DipCmd GOF)

pOrd = do
  tok1 (DipCmd ORD)
  turn <- paren pTurn
  order <- paren pOrder
  result <- paren pResult
  return (OrderResult turn order result)

pResult = do
  normal <- pMaybe pResultNormal
  retreat <- pMaybe pResultRetreat
  when (isNothing normal && isNothing retreat) (parserFail "Empty ORD result")
  return (Result normal retreat)
  

pResultNormal :: DipParser ResultNormal
pResultNormal = (tok1 (DipResult FLD) >> parserFail "FLD token received") <|>
                tok (\t -> Just $ case t of 
                        { DipResult SUC -> Success
                        ; DipResult BNC -> MoveBounced
                        ; DipResult CUT -> SupportCut
                        ; DipResult DSR -> DisbandedConvoy
                        ; DipResult NSO -> NoSuchOrder
                        })

pResultRetreat = return ResultRetreat << tok1 (DipResult RET)

pSve = do
  tok1 (DipCmd SVE)
  gameName <- paren pStr
  return (SaveGame gameName)
  
pLod = do
  tok1 (DipCmd LOD)
  gameName <- paren pStr
  return (LoadGame gameName)

pOff = do
  tok1 (DipCmd OFF)
  return (ExitClient)

pTme = do
  tok1 (DipCmd TME)
  timeLeft <- paren pInt
  return (TimeUntilDeadline timeLeft)

pError :: DipParser DipMessage
pError = do
  err <- choice [ pPrn, pHuh, pCcd ]
  return (DipError err)

pPrn = do
  tok1 (DipCmd PRN)
  message <- paren pStr
  return (WrongParen message)

pHuh = do
  tok1 (DipCmd HUH)
  message <- paren pStr
  return (SyntaxError message)

pCcd = do
  tok1 (DipCmd CCD)
  power <- paren pPower
  return (CivilDisorder power)
  

pAdm = do
  tok1 (DipCmd ADM)
  name <- paren pStr
  message <- paren pStr
  return (AdminMessage name message)

pSlo = do
  tok1 (DipCmd SLO)
  power <- paren pPower
  return (SoloWinGame power)

pDrw = do
  tok1 (DipCmd DRW)
  return (DrawGame)

{-
pPlayerStat = do
  power <- pPower
  name <- paren pStr
  message <- paren pStr
  centres <- pInt
  yearOfElimination <- pMaybe pInt
  return (PlayerStat power name message centres yearOfElimination)

pSmr = do
  tok1 (DipCmd SMR)
  turn <- paren pTurn
  playerStats <- many (paren pPlayerStat)
  return (EndGameStats turn playerStats)
-}

