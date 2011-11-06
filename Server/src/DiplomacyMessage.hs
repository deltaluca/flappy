{-# LANGUAGE FlexibleInstances, FlexibleContexts, MultiParamTypeClasses, FunctionalDependencies, NoMonomorphismRestriction #-}
module DiplomacyMessage where

import DiplomacyToken as Tok
import DiplomacyData as Dat
import DiplomacyError

import Data.Maybe
import Control.Monad.Identity
import Control.Monad.Error
import Control.Monad.Reader

import qualified Data.ByteString as BS
import qualified Text.Parsec as Parsec
import qualified Data.Map as Map

-- DipParser is a Reader (for the press level) wrapped in Parsec
newtype DipParser s a =
  DipParser {unDipParser :: (Parsec.ParsecT s () (Reader Int) a)}

type DipParserToken = DipParser [DipToken]
type DipParserString = DipParser BS.ByteString

-- which is why you should ALWAYS have an accompanying class
parserFail :: DipRep s t => String -> DipParser s a
parserFail = DipParser . Parsec.parserFail
getPosition = DipParser Parsec.getPosition
tokenPrim a b c = DipParser $ Parsec.tokenPrim a b c
spaces :: DipParserString ()
spaces = DipParser Parsec.spaces
integer :: DipParserString Int
integer = pStr >>= return . read
many = DipParser . Parsec.many . unDipParser
letter = DipParser Parsec.letter
choice = DipParser . Parsec.choice . map unDipParser
try = DipParser . Parsec.try . unDipParser
char = DipParser . Parsec.char

infixl 4 <|>
a <|> b = DipParser $ unDipParser a Parsec.<|> unDipParser b

instance Monad (DipParser s) where
  return = DipParser . return
  a >>= b = DipParser $ unDipParser a >>= \c -> unDipParser (b c)

instance MonadReader Int (DipParser s) where
  ask = DipParser ask
  local f = DipParser . local f . unDipParser

  -- Things to look out for:
  -- ambiguity: StartPing and MissingReq
  -- Cancel (StartProcessing) means dont process until deadline (ignore?)

  -- |class to abstract away the token and text representation
class Parsec.Stream s (Reader Int) t => DipRep s t | t -> s where
  pChr :: DipParser s Char
  pStr :: DipParser s [Char]
  pInt :: DipParser s Int
  tok :: (DipToken -> Maybe a) -> DipParser s a
  tok1 :: DipToken -> DipParser s DipToken
  paren :: DipParser s a -> DipParser s a

  -- defaults
  pStr = many pChr
  tok1 t = tok (mayEq t)

instance DipRep [DipToken] DipToken where
  pChr = tok (\t -> case t of {Character c -> Just c ; _ -> Nothing})
  pInt = tok (\t -> case t of {DipInt i -> Just i ; _ -> Nothing})
  paren p = tok1 Bra >> p >>= \ret -> tok1 Ket >> return ret
  tok = (\f -> getPosition >>= \p -> tokenPrim show (const . const . const $ p) f)
  

instance DipRep BS.ByteString Char where
  tok f = try $ do
    spaces
    str <- pStr
    let mTok = Map.lookup str tokenMap
    tk <- (maybe (parserFail ("unknown token: " ++ str)) return mTok)
    spaces
    maybe (parserFail "") return (f tk)
  pChr = letter
  pInt = spaces >> integer >>= \r -> spaces >> return r
  paren p = do
    spaces
    char '('
    spaces
    ret <- p
    spaces
    char ')'
    spaces
    return ret
  pStr = spaces >> many pChr >>= \r -> spaces >> return r

  -- DESC (SENDING PARTY)
data DipMessage =

    -- |first message (CLIENT)
    Name { startName :: String
       , startVersion :: String }

    -- |client is observer (CLIENT)
  | Observer

    -- |client wants to rejoin (CLIENT)
  | Rejoin { rejoinPower :: Power
           , rejoinPasscode :: Int }

    -- |map name (SERVER)
  | MapName { mapNameName :: String }

    -- |requesting map name (CLIENT)
  | MapNameReq

    -- |definition of the map (SERVER)
  | MapDef { mapDefPowers :: [Power]
           , mapDefProvinces :: Provinces
           , mapDefAdjacencies :: [Adjacency] }

    -- |requesting the definition of the map (CLIENT)
  | MapDefReq

    -- |accept message (SERVER, CLIENT)
  | Accept DipMessage

    -- |reject message (SERVER, CLIENT)
  | Reject DipMessage

    -- |cancel message (CLIENT)
  | Cancel DipMessage

    -- |game is starting
  | Start { startPower :: Power
          , startPasscode :: Int
          , startLevel :: Int
          , startVariantOpts :: [VariantOption] }

    -- |requesting whether game started (CLIENT) or replying yes (SERVER)
  | StartPing

    -- |current position (SERVER)
  | CurrentPosition [SupplyCentre]

    -- |current position request (CLIENT)
  | CurrentPositionReq

    -- |current position of units (SERVER)
  | CurrentUnitPosition Turn [UnitPosition] (Maybe [ProvinceNode])

    -- |current position of units request (CLIENT)
  | CurrentUnitPositionReq

    -- |history requested (CLIENT)
  | HistoryReq Turn

    -- |submitting orders (CLIENT)
  | SubmitOrder (Maybe Turn) [Order]

    -- |acknowledge order (SERVER)
  | AckOrder Order OrderNote

    -- |missing movement orders (SERVER)
  | MissingMovement [UnitPosition]

    -- |missing retreat orders (SERVER)
  | MissingRetreat [(UnitPosition, [ProvinceNode])]

    -- |missing build orders (SERVER)
  | MissingBuild Int

    -- |missing request (CLIENT) or replying 'no more missing request' (SERVER)
  | MissingReq

    -- |start processing orders (CLIENT) (Missing... follows)
  | StartProcessing

    -- |result of an order after turn is processed (SERVER)
  | OrderResult Turn Order Result

    -- |save game (SERVER)
  | SaveGame String

    -- |load game (SERVER)
  | LoadGame String

    -- |tell client to exit (SERVER)
  | ExitClient

    -- |time in seconds until next deadline (SERVER)
  | TimeUntilDeadline Int

    -- |throw a Diplomacy Error (SERVER, CLIENT)
  | DipError DipError

    -- |admin message sent from client to server (CLIENT)
  | AdminMessage { playerName :: String
                 , adminMessage :: String }

    -- |game has ended due to a solo by specified power (SERVER)
  | SoloWinGame { soloPower :: Power }

    -- |command sent from client to server to indicate a draw (SERVER, CLIENT)
  | DrawGame (Maybe [Power])

    -- |send press (CLIENT)
  | SendPress (Maybe Turn) [Power] PressMessage

    -- |receive press (SERVER)
  | ReceivePress Power [Power] PressMessage

    -- |sent if press is to be sent to an eliminated power (SERVER)
  | PowerEliminated Power

    -- |full statistics at the end of the game
  | EndGameStats Turn [PlayerStat]

  deriving (Show)

data PlayerStat = PlayerStat Power String String Int (Maybe Int)
                deriving (Show)

data Order = OrderMovement OrderMovement
           | OrderRetreat OrderRetreat
           | OrderBuild OrderBuild
           deriving (Show)

data PressMessage = PressProposal PressProposal
                  | PressReply PressReply
                  | PressInfo PressProposal
                  | PressCapable [DipToken]
                  deriving (Show)

data PressReply = PressAccept PressMessage
                | PressReject PressMessage
                | PressRefuse PressMessage
                | PressHuh PressMessage
                | PressCancel PressMessage
                deriving (Show)

data PressProposal = ArrangeDraw
                   | ArrangeSolo Power
                   | ArrangeAlliance [Power] [Power]
                   | ArrangePeace [Power]
                   | ArrangeNot PressProposal
                   | ArrangeUndo PressProposal
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
                   | PartialDraws              -- (10)
                   | NoPressDuringRetreat      -- (10)
                   | NoPressDuringBuild        -- (10)
                   | PressTimeTillDeadline Int -- (10)
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

parseDipMessage :: DipRep s t => Monad m => Int -> s -> ErrorT DipError m DipMessage
parseDipMessage = parseDip pMsg

parseDip :: (Monad m, DipRep s t) => DipParser s a -> Int -> s -> ErrorT DipError m a
parseDip parsr lvl toks =
  liftEither . return . mapEitherLeft (ParseError . show) . runReader (Parsec.runParserT (unDipParser parsr) () "Whatevs" toks) $ lvl


liftEither :: (Error e, Monad m) => m (Either e a) -> ErrorT e m a
liftEither a = lift a >>= either throwError return

mapEitherLeft :: (a -> b) -> (Either a c -> Either b c)
mapEitherLeft f = either (Left . f) (Right . id)

infixr 4 <<
(<<) :: Monad m => m a -> m b -> m a
a << b = b >>= (\_ -> a)

mayEq a b = if a == b then Just a else Nothing

level :: DipRep s t => Int -> DipParser s a -> DipParser s a
level l p = do
  lvl <- ask
  if lvl < l
    then do
    rest <- many (tok Just)
    parserFail $ "Level " ++ show l ++ " needed to parse " ++ show rest ++ ", I only have level " ++ show lvl
    else p

pMsg :: DipRep s t => DipParser s DipMessage
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
              , pSmr
              ]

pAccept = return . Accept =<< (tok1 (DipCmd YES) >> paren pMsg)
pReject = return . Reject =<< (tok1 (DipCmd REJ) >> paren pMsg)
pCancel = return . Cancel =<< (tok1 (DipCmd NOT) >> paren pMsg)

pNme = do
  tok1 (DipCmd NME)
  sName <- paren pStr
  sVersion <- paren pStr
  return (Name sName sVersion)

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
  supplyCentres <- paren (many (paren pSupplyCentre))
  nonSupplyCentres <- paren (many pProvince)
  return (Provinces supplyCentres nonSupplyCentres)

pAdjacency = do
  province <- pProvince
  unitToProvs <- many (paren (pUnitToProv <|> pCoastalFleetToProv))
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

pCoast :: DipRep s t => DipParser s Coast
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
  (lvl, variantOpts) <- paren pVariant
  return (Start pow passCode lvl variantOpts)

pStartPing = return StartPing

pVariant = do
  options <- many pVariantOpt
  let (lvls, others) = splitWith (\v -> case v of {Level _ -> True ; _ -> False}) options
  case lvls of
    (Level lvl) : _ -> return (lvl, others)
    _ -> parserFail "No LVL option specified in HLO message"

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
  tok1 (DipParam MRT)
  retreats <- pMaybe ((paren . many . paren) pProvinceNode)
  return (CurrentUnitPosition turn unitPoss retreats)

pCurrentUnitPosReq = return CurrentUnitPositionReq

pUnitPosition = do
  pow <- pPower
  typ <- pUnitType
  provNode <- pProvinceNode
  return (UnitPosition pow typ provNode)

pHistoryReq = return . HistoryReq =<< (tok1 (DipCmd HST) >> paren pTurn)

splitWith b x = (filter b x, filter (not . b) x)

pMaybe :: DipRep s t => DipParser s a -> DipParser s (Maybe a)
pMaybe a = (try a >>= return . Just) <|> return Nothing

pSub = do
  turn <- (tok1 (DipCmd SUB) >> pMaybe (paren pTurn))
  orders <- many (paren pOrderOrWaive)
  return (SubmitOrder turn orders)

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

pOrderNote = tok (\t -> case t of {DipOrderNote tk ->
                                      (case tk of
                                          MBV -> Just MovementOK
                                          FAR -> Just NotAdjacent
                                          NSP -> Just NoSuchProvince
                                          NSU -> Just NoSuchUnit
                                          NAS -> Just NotAtSea
                                          NSF -> Just NoSuchFleet
                                          NSA -> Just NoSuchArmy
                                          NYU -> Just NotYourUnit
                                          NRN -> Just NoRetreatNeeded
                                          NVR -> Just InvalidRetreatSpace
                                          YSC -> Just NotYourSC
                                          ESC -> Just NotEmptySC
                                          HSC -> Just NotHomeSC
                                          NSC -> Just NotASC
                                          CST -> Just InvalidBuildLocation
                                          NMB -> Just NoMoreBuildAllowed
                                          NMR -> Just NoMoreRemovalAllowed
                                          NRS -> Just NotCurrentSeason
                                          BPR -> Nothing -- error message?
                                          NST -> Nothing -- error message?
                                      ) ; _ -> Nothing})

    -- "try" used because of the freaking 2.3gajillion token lookahead
pMis = tok1 (DipCmd MIS) >>
       choice [ return . MissingMovement =<< (try . many . paren) pUnitPosition
              , return . MissingRetreat =<< (try . many . paren . pPair)
                (pUnitPosition, tok1 (DipParam MRT) >> paren (many pProvinceNode))
              , return . MissingBuild =<< paren pInt
              , return MissingReq
              ]

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


pResultNormal = (tok1 (DipResult FLD) >> parserFail "FLD token received") <|>
                tok (\t -> case t of
                        { DipResult SUC -> Just Success
                        ; DipResult BNC -> Just MoveBounced
                        ; DipResult CUT -> Just SupportCut
                        ; DipResult DSR -> Just DisbandedConvoy
                        ; DipResult NSO -> Just NoSuchOrder
                        ; _ -> Nothing
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

pError = do
  err <- choice [ pPrn, pHuh, pCcd ]
  return (DipError err)

pToken = tok Just

pPrn = do
  tok1 (DipCmd PRN)
  message <- paren (many pToken)
  return (WrongParen message)

pHuh = do
  tok1 (DipCmd HUH)
  message <- paren (many pToken)
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
  mPowers <- pMaybe . level 10 . many . paren $ pPower
  return (DrawGame mPowers)

pSnd = level 10 $ do
  tok1 (DipCmd SND)
  mTurn <- pMaybe (paren pTurn)
  powers <- paren (many pPower)
  pMessage <- paren pPressMessage
  return (SendPress mTurn powers pMessage)

pOut = level 10 $ do
  tok1 (DipCmd OUT)
  power <- paren pPower
  return (PowerEliminated power)

pFrm = level 10 $ do
  tok1 (DipCmd FRM)
  fromPower <- paren pPower
  toPowers <- paren (many pPower)
  msg <- paren pPressMessage
  return (ReceivePress fromPower toPowers msg)

pPressMessage = level 10 (choice [ pPressProposal
                                 , pPressReply])

pPressProposal = do
  tok1 (DipPress PRP)
  return . PressProposal =<< paren pPressArrangement

pPressArrangement = choice [ pPressPeace
                           , pPressAlliance
                           , pPressDraw
                           , pPressSolo
                           , pPressArrangeNot
                           , pPressArrangeUndo
                           ]

pPressDraw = tok1 (DipCmd DRW) >> return ArrangeDraw

pPressSolo = do
  tok1 (DipCmd SLO)
  power <- paren pPower
  return (ArrangeSolo power)

pPressPeace = do
  tok1 (DipPress PCE)
  powers <- paren (many pPower)
  return (ArrangePeace powers)

pPressAlliance = do
  tok1 (DipPress ALY)
  allies <- paren (many pPower)
  tok1 (DipPress VSS)
  enemies <- paren (many pPower)
  return (ArrangeAlliance allies enemies)

pPressArrangeNot = do
  tok1 (DipCmd NOT)
  arrangement <- pPressArrangement
  return (ArrangeNot arrangement)

pPressArrangeUndo = do
  tok1 (DipPress NAR)
  arrangement <- pPressArrangement
  return (ArrangeUndo arrangement)

pPressReply = return . PressReply =<< choice [ pPressRefuse
                                             , pPressReject
                                             , pPressAccept
                                             , pPressCancel
                                             , pPressHuh
                                             ]

pPressHuh = do
  tok1 (DipCmd HUH)
  msg <- paren pPressMessage
  return (PressHuh msg)

pPressAccept = do
  tok1 (DipCmd YES)
  msg <- paren pPressMessage
  return (PressAccept msg)

pPressReject = do
  tok1 (DipCmd REJ)
  msg <- paren pPressMessage
  return (PressReject msg)

pPressRefuse = do
  tok1 (DipPress BWX)
  msg <- paren pPressMessage
  return (PressRefuse msg)

pPressCancel = do
  tok1 (DipPress CCL)
  msg <- paren pPressMessage
  return (PressCancel msg)

pPressInfo = do
  tok1 (DipPress FCT)
  arrangement <- paren pPressArrangement
  return (PressInfo arrangement)

pPressTry = do
  tok1 (DipPress TRY)
  tks <- paren (many pToken)
  return (PressCapable tks)

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
