{-# LANGUAGE FlexibleInstances, FlexibleContexts, MultiParamTypeClasses, FunctionalDependencies, GeneralizedNewtypeDeriving #-}
module Diplomacy.Common.DipMessage (DipMessage(..), parseDipMessage) where

import Diplomacy.Common.Data as Dat
import Diplomacy.Common.DipToken
import Diplomacy.Common.DipError

import Data.Maybe
import Control.Monad.Error
import Control.Monad.Reader
import Control.Monad.State

import qualified Data.ByteString.Char8 as BS
import qualified Text.Parsec as Parsec
import qualified Data.Map as Map

  -- level and custom error
type DipParserInfo = StateT (Maybe DipParseError) (Reader Int)

-- DipParser is a ReaderT (for the press level) wrapped in StateT (for custom errors) wrapped in  Parsec
newtype DipParser s a =
  DipParser {unDipParser :: (Parsec.ParsecT s () DipParserInfo a)}
  deriving (Monad, MonadReader Int, MonadState (Maybe DipParseError))


type DipParserString = DipParser BS.ByteString

-- which is why you should ALWAYS have an accompanying class
parserFail :: DipRep s t => String -> DipParser s a
parserFail = dipCatchError . Parsec.parserFail
getPosition = dipCatchError Parsec.getPosition
tokenPrim a b c = dipCatchError $ Parsec.tokenPrim a b c

spaces :: DipParserString ()
spaces = dipCatchError Parsec.spaces

integer :: DipParserString Int
integer = pStr >>= return . read

many :: DipRep s t => DipParser s a -> DipParser s [a]
many = dipCatchError . Parsec.many . unDipParser

letter = dipCatchError Parsec.letter

choice :: DipRep s t => [DipParser s a] -> DipParser s a
choice = dipCatchError . Parsec.choice . map unDipParser

try :: DipRep s t => DipParser s a -> DipParser s a
try = dipCatchError . Parsec.try . unDipParser
char = dipCatchError . Parsec.char

infixl 4 <|>
a <|> b = DipParser $ unDipParser a Parsec.<|> unDipParser b

infixl 4 <?>
a <?> b = a <|> putDipError b

putDipError :: DipRep s t => (Int -> DipParseError) -> DipParser s a
putDipError e = do
  pos <- errPos
  put (Just (e pos))
  parserFail "XXX"

dipCatchError :: DipRep s t => Parsec.ParsecT s () DipParserInfo a -> DipParser s a
dipCatchError parsr = DipParser parsr <?> SyntaxError

  -- Things to look out for:
  -- ambiguity: StartPing and MissingReq
  -- Cancel (StartProcessing) means dont process until deadline (ignore?)

  -- |class to abstract away the token and text representation
class Parsec.Stream s DipParserInfo t => DipRep s t | t -> s where
  pChr :: DipParser s Char
  pStr :: DipParser s [Char]
  pInt :: DipParser s Int
  tok :: (DipToken -> Maybe a) -> DipParser s a
  tok1 :: DipToken -> DipParser s DipToken
  paren :: DipParser s a -> DipParser s a
  errPos :: DipParser s Int
  createError :: DipParseError -> s -> DipError

  -- defaults
  pStr = many pChr
  tok1 t = tok (mayEq t)

instance DipRep [DipToken] DipToken where
  pChr = tok (\t -> case t of {Character c -> Just c ; _ -> Nothing})
  pInt = tok (\t -> case t of {DipInt i -> Just i ; _ -> Nothing})
  paren p = tok1 Bra >> p >>= \ret -> tok1 Ket >> return ret
  tok = (\f -> getPosition >>= \p -> tokenPrim show (const . const . const $ p) f)
  errPos = getPosition >>= return . Parsec.sourceColumn
  createError (WrongParen pos) toks = Paren $ DipCmd PRN : listify (uParen (insertAt pos (DipParam ERR)) . (appendListify toks))
  createError (SyntaxError pos) toks = Paren $ DipCmd PRN : listify (uParen (insertAt pos (DipParam ERR)) . (appendListify toks))

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
    char '(' <?> WrongParen
    spaces
    ret <- p
    spaces
    char ')' <?> WrongParen
    spaces
    return ret
  pStr = spaces >> many pChr >>= \r -> spaces >> return r
  errPos = return 0
  createError (WrongParen _) _ = Paren []
  createError (SyntaxError _) _ = Syntax []

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
parseDip parsr lvl stream =   uncurry (handleParseErrors stream)
                            . flip runReader lvl
                            . flip runStateT Nothing
                            . Parsec.runParserT (unDipParser parsr) () "DAIDE Message Parser"
                            $ stream


handleParseErrors :: (Monad m, DipRep s t) => s -> Either Parsec.ParseError a -> (Maybe DipParseError) -> ErrorT DipError m a
handleParseErrors stream (Left _) (Just err) = throwError (createError err stream)
handleParseErrors _ (Left p) Nothing = throwError . ParseError . show $ p
handleParseErrors _ (Right a) _ = return a

infixr 4 <<
(<<) :: Monad m => m a -> m b -> m a
(<<) = flip (>>)

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
pMsg = choice  [ pAccept, pReject, pCancel
               , pNme, pIam, pObs
               , pMap, pMdf
               , pHlo
               , pSco, pNow, pHistoryReq
               , pSub, pMis, pAck
               , pGof
               , pOrd
               , pSve, pLod
               , pOff
               , pTme
               , pError
               , pAdm
               , pSlo
               , pDrw
               , pSmr
                
                 -- press
               , pSnd
               , pOut
               , pFrm
              ]

pAccept :: DipRep s t => DipParser s DipMessage
pAccept = return . Accept =<< (tok1 (DipCmd YES) >> paren pMsg)
pReject :: DipRep s t => DipParser s DipMessage
pReject = return . Reject =<< (tok1 (DipCmd REJ) >> paren pMsg)
pCancel :: DipRep s t => DipParser s DipMessage
pCancel = return . Cancel =<< (tok1 (DipCmd NOT) >> paren pMsg)

pNme :: DipRep s t => DipParser s DipMessage
pNme = do
  tok1 (DipCmd NME)
  sName <- paren pStr
  sVersion <- paren pStr
  return (Name sName sVersion)

pMap :: DipRep s t => DipParser s DipMessage
pMap = tok1 (DipCmd MAP) >> choice [pMapName, pMapNameReq]

pObs :: DipRep s t => DipParser s DipMessage
pObs = tok1 (DipCmd OBS) >> return Observer

pIam :: DipRep s t => DipParser s DipMessage
pIam = do
  tok1 (DipCmd IAM)
  power <- paren pPower
  passcode <- paren pInt
  return (Rejoin power passcode)

pMapName :: DipRep s t => DipParser s DipMessage
pMapName = return . MapName =<< paren pStr

pMapNameReq :: DipRep s t => DipParser s DipMessage
pMapNameReq = return MapNameReq

pMdf :: DipRep s t => DipParser s DipMessage
pMdf = tok1 (DipCmd MDF) >> choice [pMapDef, pMapDefReq]

pMapDef :: DipRep s t => DipParser s DipMessage
pMapDef = do
  powers <- paren (many pPower)
  provinces <- paren pProvinces
  adjacencies <- paren (many (paren pAdjacency))
  return (MapDef powers provinces adjacencies)

pMapDefReq :: DipRep s t => DipParser s DipMessage
pMapDefReq = return MapDefReq

pPower :: DipRep s t => DipParser s Power
pPower = tok (\t -> case t of { DipPow (Pow p) -> Just (Power p)
                              ; DipParam UNO -> Just Neutral
                              ; _ -> Nothing})

pProvinces :: DipRep s t => DipParser s Provinces
pProvinces = do
  supplyCentres <- paren (many (paren pSupplyCentre))
  nonSupplyCentres <- paren (many pProvince)
  return (Provinces supplyCentres nonSupplyCentres)

pAdjacency :: DipRep s t => DipParser s Adjacency
pAdjacency = do
  province <- pProvince
  unitToProvs <- many (paren (pUnitToProv <|> pCoastalFleetToProv))
  return (Adjacency province unitToProvs)

pUnitToProv :: DipRep s t => DipParser s UnitToProv
pUnitToProv = do
  unitType <- pUnitType
  provNodes <- many pProvinceNode
  return (UnitToProv unitType provNodes)

pCoastalFleetToProv :: DipRep s t => DipParser s UnitToProv
pCoastalFleetToProv = do
  coast <- paren (tok1 (DipUnitType Fleet) >> pCoast)
  provNodes <- many pProvinceNode
  return (CoastalFleetToProv coast provNodes)

pUnitType :: DipRep s t => DipParser s UnitType
pUnitType = tok (\t -> case t of {DipUnitType typ -> Just typ ; _ -> Nothing})

pCoast :: DipRep s t => DipParser s Coast
pCoast = tok (\t -> case t of {DipCoast c -> Just c ; _ -> Nothing})

pProvinceNode :: DipRep s t => DipParser s ProvinceNode
pProvinceNode = (return . ProvNode =<< pProvince) <|>
                (paren $ do
                    prov <- pProvince
                    c <- pCoast
                    return (ProvCoastNode prov c))

pSupplyCentre :: DipRep s t => DipParser s SupplyCentre
pSupplyCentre = do
  pow <- pPower
  centres <- many pProvince
  return (SupplyCentre pow centres)

pProvince :: DipRep s t => DipParser s Province
pProvince = tok (\t -> case t of {(DipProv p) -> Just p ; _ -> Nothing})

pHlo :: DipRep s t => DipParser s DipMessage
pHlo = tok1 (DipCmd HLO) >> choice [pStart, pStartPing]

pStart :: DipRep s t => DipParser s DipMessage
pStart = do
  pow <- paren pPower
  passCode <- paren pInt
  (lvl, variantOpts) <- paren pVariant
  return (Start pow passCode lvl variantOpts)

pStartPing :: DipRep s t => DipParser s DipMessage
pStartPing = return StartPing


pVariant :: DipRep s t => DipParser s (Int, [VariantOption])
pVariant = do
  options <- many pVariantOpt
  let (lvls, others) = splitWith (\v -> case v of {Level _ -> True ; _ -> False}) options
  case lvls of
    (Level lvl) : _ -> return (lvl, others)
    _ -> parserFail "No LVL option specified in HLO message"

pVariantOpt :: DipRep s t => DipParser s VariantOption
pVariantOpt = choice [ return . Level         =<< (tok1 (DipParam LVL) >> pInt)
                     , return . TimeMovement  =<< (tok1 (DipParam MTL) >> pInt)
                     , return . TimeRetreat   =<< (tok1 (DipParam RTL) >> pInt)
                     , return . TimeBuild     =<< (tok1 (DipParam BTL) >> pInt)
                     , return DeadlineStop     << (tok1 (DipParam DSD))
                     , return AnyOrderAccepted << (tok1 (DipParam AOA))
                     ]

pSco :: DipRep s t => DipParser s DipMessage
pSco = tok1 (DipCmd SCO) >> choice [pCurrentPos, pCurrentPosReq]

pCurrentPos :: DipRep s t => DipParser s DipMessage
pCurrentPos = return . CurrentPosition =<< many (paren pSupplyCentre)

pCurrentPosReq :: DipRep s t => DipParser s DipMessage
pCurrentPosReq = return CurrentPositionReq

pPhase :: DipRep s t => DipParser s Phase
pPhase = tok (\t -> case t of {DipPhase p -> Just p ; _ -> Nothing})

pTurn :: DipRep s t => DipParser s Turn
pTurn = do
  phase <- pPhase
  year <- pInt
  return (Turn phase year)

pNow :: DipRep s t => DipParser s DipMessage
pNow = tok1 (DipCmd NOW) >> choice [pCurrentUnitPos, pCurrentUnitPosReq]

pCurrentUnitPos :: DipRep s t => DipParser s DipMessage
pCurrentUnitPos = do
  turn <- paren pTurn
  unitPoss <- many (paren pUnitPosition)
  tok1 (DipParam MRT)
  retreats <- pMaybe ((paren . many . paren) pProvinceNode)
  return (CurrentUnitPosition turn unitPoss retreats)

pCurrentUnitPosReq :: DipRep s t => DipParser s DipMessage
pCurrentUnitPosReq = return CurrentUnitPositionReq

pUnitPosition :: DipRep s t => DipParser s UnitPosition
pUnitPosition = do
  pow <- pPower
  typ <- pUnitType
  provNode <- pProvinceNode
  return (UnitPosition pow typ provNode)

pHistoryReq :: DipRep s t => DipParser s DipMessage
pHistoryReq = return . HistoryReq =<< (tok1 (DipCmd HST) >> paren pTurn)

splitWith b x = (filter b x, filter (not . b) x)

pMaybe :: DipRep s t => DipParser s a -> DipParser s (Maybe a)
pMaybe a = (try a >>= return . Just) <|> return Nothing

pSub :: DipRep s t => DipParser s DipMessage
pSub = do
  turn <- (tok1 (DipCmd SUB) >> pMaybe (paren pTurn))
  orders <- many (paren pOrderOrWaive)
  return (SubmitOrder turn orders)

pOrderOrWaive :: DipRep s t => DipParser s Order
pOrderOrWaive = pOrder <|> do
  tok1 (DipOrder WVE)
  power <- pPower
  return (OrderBuild (Waive power))

pOrder :: DipRep s t => DipParser s Order
pOrder = do
  unit <- paren (pUnitPosition)
  choice . map ($ unit) $ [ pHld, pMto, pSup, pCvy, pCto -- move
                          , pRto, pDsb                   -- retreat
                          , pBld, pRem]                  -- build

pHld :: DipRep s t => UnitPosition -> DipParser s Order
pHld u = do
  tok1 (DipOrder HLD)
  return . OrderMovement . Hold $ u


pMto :: DipRep s t => UnitPosition -> DipParser s Order
pMto u = return . OrderMovement . Move u =<< (tok1 (DipOrder MTO) >> pProvinceNode)


pSup :: DipRep s t => UnitPosition -> DipParser s Order
pSup u1 = do
  tok1 (DipOrder SUP)
  u2 <- paren pUnitPosition
  pSupMove u1 u2 <|> pSupHold u1 u2

pSupMove :: DipRep s t => UnitPosition -> UnitPosition -> DipParser s Order
pSupMove u1 u2 = do
  tok1 (DipOrder MTO)
  return . OrderMovement . SupportMove u1 u2 =<< pProvince

pSupHold :: DipRep s t => UnitPosition -> UnitPosition -> DipParser s Order
pSupHold u1 u2 = return . OrderMovement . SupportHold u1 $ u2

pCvy :: DipRep s t => UnitPosition -> DipParser s Order
pCvy u1 = do
  tok1 (DipOrder CVY)
  u2 <- paren pUnitPosition
  tok1 (DipOrder CTO)
  return . OrderMovement . Convoy u1 u2 =<< pProvinceNode

pCto :: DipRep s t => UnitPosition -> DipParser s Order
pCto u = do
  tok1 (DipOrder CTO)
  prov <- pProvinceNode
  tok1 (DipOrder VIA)
  return . OrderMovement . MoveConvoy u prov =<< paren (many pProvince)

pRto :: DipRep s t => UnitPosition -> DipParser s Order
pRto u = return . OrderRetreat . Retreat u =<< (tok1 (DipOrder RTO) >> pProvinceNode)

pDsb :: DipRep s t => UnitPosition -> DipParser s Order
pDsb u = (return . OrderRetreat . Disband) u << tok1 (DipOrder DSB)

pBld :: DipRep s t => UnitPosition -> DipParser s Order
pBld u = (return . OrderBuild . Build) u << tok1 (DipOrder BLD)

pRem :: DipRep s t => UnitPosition -> DipParser s Order
pRem u = (return . OrderBuild . Remove) u << tok1 (DipOrder REM)

pAck :: DipRep s t => DipParser s DipMessage
pAck = do
  tok1 (DipCmd THX)
  order <- paren pOrder
  orderNote <- paren pOrderNote
  return (AckOrder order orderNote)

pOrderNote :: DipRep s t => DipParser s OrderNote
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
pMis :: DipRep s t => DipParser s DipMessage
pMis = tok1 (DipCmd MIS) >>
       choice [ return . MissingMovement =<< (try . many . paren) pUnitPosition
              , return . MissingRetreat =<< (try . many . paren . pPair)
                (pUnitPosition, tok1 (DipParam MRT) >> paren (many pProvinceNode))
              , return . MissingBuild =<< paren pInt
              , return MissingReq
              ]

pPair :: DipRep s t => (DipParser s a, DipParser s b) -> DipParser s (a, b)
pPair (a, b) = do
  aRes <- a
  bRes <- b
  return (aRes, bRes)

pGof :: DipRep s t => DipParser s DipMessage
pGof = return StartProcessing << tok1 (DipCmd GOF)

pOrd :: DipRep s t => DipParser s DipMessage
pOrd = do
  tok1 (DipCmd ORD)
  turn <- paren pTurn
  order <- paren pOrder
  result <- paren pResult
  return (OrderResult turn order result)

pResult :: DipRep s t => DipParser s Result
pResult = do
  normal <- pMaybe pResultNormal
  retreat <- pMaybe pResultRetreat
  when (isNothing normal && isNothing retreat) (parserFail "Empty ORD result")
  return (Result normal retreat)


pResultNormal :: DipRep s t => DipParser s ResultNormal
pResultNormal = (tok1 (DipResult FLD) >> parserFail "FLD token received") <|>
                tok (\t -> case t of
                        { DipResult SUC -> Just Success
                        ; DipResult BNC -> Just MoveBounced
                        ; DipResult CUT -> Just SupportCut
                        ; DipResult DSR -> Just DisbandedConvoy
                        ; DipResult NSO -> Just NoSuchOrder
                        ; _ -> Nothing
                        })

pResultRetreat :: DipRep s t => DipParser s ResultRetreat
pResultRetreat = return ResultRetreat << tok1 (DipResult RET)

pSve :: DipRep s t => DipParser s DipMessage
pSve = do
  tok1 (DipCmd SVE)
  gameName <- paren pStr
  return (SaveGame gameName)

pLod :: DipRep s t => DipParser s DipMessage
pLod = do
  tok1 (DipCmd LOD)
  gameName <- paren pStr
  return (LoadGame gameName)

pOff :: DipRep s t => DipParser s DipMessage
pOff = do
  tok1 (DipCmd OFF)
  return (ExitClient)

pTme :: DipRep s t => DipParser s DipMessage
pTme = do
  tok1 (DipCmd TME)
  timeLeft <- paren pInt
  return (TimeUntilDeadline timeLeft)

pError :: DipRep s t => DipParser s DipMessage
pError = do
  err <- choice [ pPrn, pHuh, pCcd ]
  return (DipError err)

pToken :: DipRep s t => DipParser s DipToken
pToken = tok Just

pPrn :: DipRep s t => DipParser s DipError
pPrn = do
  tok1 (DipCmd PRN)
  message <- paren (many pToken)
  return (Paren message)

pHuh :: DipRep s t => DipParser s DipError
pHuh = do
  tok1 (DipCmd HUH)
  message <- paren (many pToken)
  return (Syntax message)

pCcd :: DipRep s t => DipParser s DipError
pCcd = do
  tok1 (DipCmd CCD)
  power <- paren pPower
  return (CivilDisorder power)


pAdm :: DipRep s t => DipParser s DipMessage
pAdm = do
  tok1 (DipCmd ADM)
  name <- paren pStr
  message <- paren pStr
  return (AdminMessage name message)

pSlo :: DipRep s t => DipParser s DipMessage
pSlo = do
  tok1 (DipCmd SLO)
  power <- paren pPower
  return (SoloWinGame power)

pDrw :: DipRep s t => DipParser s DipMessage
pDrw = do
  tok1 (DipCmd DRW)
  mPowers <- pMaybe . level 10 . many . paren $ pPower
  return (DrawGame mPowers)

pSnd :: DipRep s t => DipParser s DipMessage
pSnd = level 10 $ do
  tok1 (DipCmd SND)
  mTurn <- pMaybe (paren pTurn)
  powers <- paren (many pPower)
  pMessage <- paren pPressMessage
  return (SendPress mTurn powers pMessage)

pOut :: DipRep s t => DipParser s DipMessage
pOut = level 10 $ do
  tok1 (DipCmd OUT)
  power <- paren pPower
  return (PowerEliminated power)

pFrm :: DipRep s t => DipParser s DipMessage
pFrm = level 10 $ do
  tok1 (DipCmd FRM)
  fromPower <- paren pPower
  toPowers <- paren (many pPower)
  msg <- paren pPressMessage
  return (ReceivePress fromPower toPowers msg)

pPressMessage :: DipRep s t => DipParser s PressMessage
pPressMessage = level 10 (choice [ pPressProposal
                                 , pPressReply
                                 , pPressInfo
                                 , pPressTry
                                 ])

pPressProposal :: DipRep s t => DipParser s PressMessage
pPressProposal = do
  tok1 (DipPress PRP)
  return . PressProposal =<< paren pPressArrangement

pPressArrangement :: DipRep s t => DipParser s PressProposal
pPressArrangement = choice [ pPressPeace
                           , pPressAlliance
                           , pPressDraw
                           , pPressSolo
                           , pPressArrangeNot
                           , pPressArrangeUndo
                           ]

pPressDraw :: DipRep s t => DipParser s PressProposal
pPressDraw = tok1 (DipCmd DRW) >> return ArrangeDraw

pPressSolo :: DipRep s t => DipParser s PressProposal
pPressSolo = do
  tok1 (DipCmd SLO)
  power <- paren pPower
  return (ArrangeSolo power)

pPressPeace :: DipRep s t => DipParser s PressProposal
pPressPeace = do
  tok1 (DipPress PCE)
  powers <- paren (many pPower)
  return (ArrangePeace powers)

pPressAlliance :: DipRep s t => DipParser s PressProposal
pPressAlliance = do
  tok1 (DipPress ALY)
  allies <- paren (many pPower)
  tok1 (DipPress VSS)
  enemies <- paren (many pPower)
  return (ArrangeAlliance allies enemies)

pPressArrangeNot :: DipRep s t => DipParser s PressProposal
pPressArrangeNot = do
  tok1 (DipCmd NOT)
  arrangement <- pPressArrangement
  return (ArrangeNot arrangement)

pPressArrangeUndo :: DipRep s t => DipParser s PressProposal
pPressArrangeUndo = do
  tok1 (DipPress NAR)
  arrangement <- pPressArrangement
  return (ArrangeUndo arrangement)

pPressReply :: DipRep s t => DipParser s PressMessage
pPressReply = return . PressReply =<< choice [ pPressRefuse
                                             , pPressReject
                                             , pPressAccept
                                             , pPressCancel
                                             , pPressHuh
                                             ]

pPressHuh :: DipRep s t => DipParser s PressReply
pPressHuh = do
  tok1 (DipCmd HUH)
  msg <- paren pPressMessage
  return (PressHuh msg)

pPressAccept :: DipRep s t => DipParser s PressReply
pPressAccept = do
  tok1 (DipCmd YES)
  msg <- paren pPressMessage
  return (PressAccept msg)

pPressReject :: DipRep s t => DipParser s PressReply
pPressReject = do
  tok1 (DipCmd REJ)
  msg <- paren pPressMessage
  return (PressReject msg)

pPressRefuse :: DipRep s t => DipParser s PressReply
pPressRefuse = do
  tok1 (DipPress BWX)
  msg <- paren pPressMessage
  return (PressRefuse msg)

pPressCancel :: DipRep s t => DipParser s PressReply
pPressCancel = do
  tok1 (DipPress CCL)
  msg <- paren pPressMessage
  return (PressCancel msg)

pPressInfo :: DipRep s t => DipParser s PressMessage
pPressInfo = do
  tok1 (DipPress FCT)
  arrangement <- paren pPressArrangement
  return (PressInfo arrangement)

pPressTry :: DipRep s t => DipParser s PressMessage
pPressTry = do
  tok1 (DipPress TRY)
  tks <- paren (many pToken)
  return (PressCapable tks)

pPlayerStat :: DipRep s t => DipParser s PlayerStat
pPlayerStat = do
  power <- pPower
  name <- paren pStr
  message <- paren pStr
  centres <- pInt
  yearOfElimination <- pMaybe pInt
  return (PlayerStat power name message centres yearOfElimination)

pSmr :: DipRep s t => DipParser s DipMessage
pSmr = do
  tok1 (DipCmd SMR)
  turn <- paren pTurn
  playerStats <- many (paren pPlayerStat)
  return (EndGameStats turn playerStats)


-- unparsing
  
type AppendList a = [a] -> [a]
cons  a = ((a :) .)
lcons a = (. (a :))
listify = ($ [])

appendListify = foldr cons id

insertAt 0 a l = a : l
insertAt n a (b : as) = b : insertAt (n - 1) a as
insertAt _ _ [] = undefined

uParen :: AppendList DipToken -> AppendList DipToken
uParen = cons Bra . lcons Ket
