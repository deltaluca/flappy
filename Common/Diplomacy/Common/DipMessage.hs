{-# LANGUAGE FlexibleInstances, FlexibleContexts, MultiParamTypeClasses, FunctionalDependencies, GeneralizedNewtypeDeriving #-}
module Diplomacy.Common.DipMessage ( DipMessage(..)
                                   , parseDipMessage
                                   , uParseDipMessage
                                   , idParse -- for testing
                                   , stringyDip) where

import Diplomacy.Common.Data as Dat
import Diplomacy.Common.Press
import Diplomacy.Common.DipToken
import Diplomacy.Common.DipError

import Data.Maybe
import Data.List
import Control.DeepSeq
import Control.Monad.Error
import Control.Monad.Reader
import Control.Monad.State
import Control.Monad.Identity

import qualified Data.ByteString.Char8 as BS
import qualified Text.Parsec as Parsec
import qualified Data.Map as Map

  -- QUICKCHECK --
import Test.QuickCheck hiding (Success, Result)
  -- level and custom error
type DipParserInfo = StateT (Maybe DipParseError) (Reader Int)

-- DipParser is a ReaderT (for the press level) wrapped in StateT (for custom errors) wrapped in  Parsec
newtype DipParser s a =
  DipParser {unDipParser :: (Parsec.ParsecT s () DipParserInfo a)}
  deriving (Monad, MonadReader Int, MonadState (Maybe DipParseError))


type DipParserString = DipParser BS.ByteString

-- which is why you should ALWAYS have an accompanying class
parserFail :: DipRep s t => String -> DipParser s a
parserFail = DipParser . Parsec.parserFail
getPosition = dipCatchError Parsec.getPosition
tokenPrim a b c = dipCatchError $ Parsec.tokenPrim a b c

spaces :: DipParserString ()
spaces = dipCatchError Parsec.spaces

eof :: DipParserString ()
eof = dipCatchError Parsec.eof

integer :: DipParserString Int
integer = pStr >>= return . read

many :: DipRep s t => DipParser s a -> DipParser s [a]
many = dipCatchError . Parsec.many . unDipParser

getInput :: DipRep s t => DipParser s s
getInput = dipCatchError Parsec.getInput

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
  eoi :: DipParser s ()

  -- defaults
  pStr = many pChr
  tok1 t = tok (mayEq t)

instance DipRep [DipToken] DipToken where
  pChr = tok (\t -> case t of {Character c -> Just c ; _ -> Nothing})
  pInt = tok (\t -> case t of {DipInt i -> Just i ; _ -> Nothing})
  paren p = tok1 Bra >> p >>= \ret -> tok1 Ket >> return ret
  tok = (\f -> getPosition >>= \p -> tokenPrim show (const . const . const $ p) f)
  errPos = getPosition >>= return . Parsec.sourceColumn
  createError (WrongParen pos) toks =
    Paren $ DipCmd PRN : listify (uParen (insertAt pos) (DipParam ERR) . (appendListify toks))
  createError (SyntaxError pos) toks = Paren $ DipCmd PRN : listify (uParen (insertAt pos) (DipParam ERR) . (appendListify toks))
  eoi = getInput >>= (\s -> if s /= [] then parserFail "End of input expected" else return ())

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
  eoi = eof

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
  | MapDef MapDefinition

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

    -- |current position of supply centers req.(SERVER)
  | CurrentPosition SupplyCOwnerships

    -- |current position request (CLIENT)
  | CurrentPositionReq

    -- |current position of units (SERVER)
  | CurrentUnitPosition Turn UnitPositions

    -- |current position of units req. (CLIENT)
  | CurrentUnitPositionReq

    -- |history requested (CLIENT)
  | HistoryReq Turn

    -- |submitting orders (CLIENT)
  | SubmitOrder (Maybe Turn) [Order]

    -- |acknowledge order (SERVER)
  | AckOrder Order OrderNote

    -- |missing orders (SERVER)
  | Missing Missing

    -- |missing request (CLIENT) or replying 'no more missing request' (SERVER)
  | MissingReq

    -- |start processing orders (CLIENT) (Missing... follows)
  | StartProcessing

    -- |result of an order after turn is processed (SERVER)
  | OrderResult Turn Order OrderResult

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
  | SendPress (Maybe Turn) OutMessage

    -- |receive press (SERVER)
  | ReceivePress InMessage

    -- |sent if press is to be sent to an eliminated power (SERVER)
  | PowerEliminated Power

    -- |full statistics at the end of the game
  | EndGameStats Turn [PlayerStat]

  deriving (Eq, Show)

instance NFData DipMessage

data Missing =
  -- |missing movement orders (SERVER)
    MissingMovement [UnitPosition]

    -- |missing retreat orders (SERVER)
  | MissingRetreat [(UnitPosition, [ProvinceNode])]

    -- |missing build orders (SERVER)
  | MissingBuild Int
  deriving (Eq, Show)

data PlayerStat = PlayerStat Power String String Int (Maybe Int)
                deriving (Eq, Show)

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
                   deriving (Eq, Show)

parseDipMessage :: (DipRep s t, Show s) => Monad m => Int -> s -> ErrorT DipError m DipMessage
parseDipMessage = parseDip pMsg

parseDip :: (Monad m, DipRep s t, Show s) => DipParser s a -> Int -> s -> ErrorT DipError m a
parseDip pars lvl stream = let parsr = pars >>= (\r -> eoi >> return r) in
  uncurry (handleParseErrors stream)
  . flip runReader lvl
  . flip runStateT Nothing
  . Parsec.runParserT (unDipParser parsr) () "DAIDE Message Parser"
  $ stream

handleParseErrors :: (Monad m, DipRep s t, Show s) => s -> Either Parsec.ParseError a -> (Maybe DipParseError) -> ErrorT DipError m a
handleParseErrors s (Left a) (Just _{-err-}) = error (show a ++ '\n' : show s) -- throwError (createError err stream)
handleParseErrors s (Left p) Nothing = error (show p ++ '\n' : show s) -- throwError . ParseError . show $ p
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
  (scos, provinces) <- paren pProvinces
  adjacencies <- paren (many (paren pAdjacency))
  return . MapDef $ MapDefinition powers provinces (Adjacencies $ (foldl (\m (k, v) -> Map.insert k v m) Map.empty) adjacencies) scos

pMapDefReq :: DipRep s t => DipParser s DipMessage
pMapDefReq = return MapDefReq

pPower :: DipRep s t => DipParser s Power
pPower = tok (\t -> case t of { DipPow (Pow p) -> Just (Power p)
                              ; DipParam UNO -> Just Neutral
                              ; _ -> Nothing})

pProvinces :: DipRep s t => DipParser s (SupplyCOwnerships, [Province])
pProvinces = do
  (SupplyCOwnerships scos) <- paren (pSupplyCOs)
  nonSupplyCentres <- paren (many pProvince)
  let allProvs = nub . (concatMap snd (Map.toList scos) ++) $ nonSupplyCentres
  return (SupplyCOwnerships scos, allProvs)

pAdjacency :: DipRep s t => DipParser s (Province, [UnitToProv])
pAdjacency = do
  province <- pProvince
  unitToProvs <- many (paren (pUnitToProv <|> pCoastalFleetToProv))
  return (province, unitToProvs)

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

pSupplyCOs :: DipRep s t => DipParser s SupplyCOwnerships
pSupplyCOs = do
  scos <- many . paren $ do
    pow <- pPower
    centres <- many pProvince
    return (pow, centres)
  return . SupplyCOwnerships . (foldl (\m (k, v) -> Map.insert k v m) Map.empty) $ scos

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
  options <- many (paren pVariantOpt)
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
pCurrentPos = return . CurrentPosition =<< pSupplyCOs

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
pNow = tok1 (DipCmd NOW) >> choice [ try pCurrentUnitPosRet
                                   , pCurrentUnitPos
                                   , pCurrentUnitPosReq ]

pCurrentUnitPosRet :: DipRep s t => DipParser s DipMessage
pCurrentUnitPosRet = do
  turn <- paren pTurn
  unitPoss <- many . paren . pPair pUnitPosition $ do
    tok1 (DipParam MRT)
    paren . many $ pProvinceNode
  return . CurrentUnitPosition turn $ UnitPositionsRet unitPoss

pCurrentUnitPos :: DipRep s t => DipParser s DipMessage
pCurrentUnitPos = do
  turn <- paren pTurn
  unitPoss <- many . paren $ pUnitPosition
  return . CurrentUnitPosition turn $ UnitPositions unitPoss

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
  power <- pPower
  tok1 (DipOrder WVE)
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
       choice [ return . Missing . MissingMovement =<< (try . many . paren) pUnitPosition
              , return . Missing . MissingRetreat =<<
                (try . many . paren . pPair pUnitPosition
                 $ tok1 (DipParam MRT) >> paren (many pProvinceNode))
              , return . Missing . MissingBuild =<< paren pInt
              , return MissingReq
              ]

pPair :: DipRep s t => DipParser s a -> DipParser s b -> DipParser s (a, b)
pPair a b = do
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

pResult :: DipRep s t => DipParser s OrderResult
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
  return (SendPress mTurn (OutMessage powers pMessage))

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
  return (ReceivePress (InMessage fromPower toPowers msg))

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

type UnParser a b = a -> AppendList b

type UnDipParser a = UnParser a DipToken

uParseDipMessage :: DipMessage -> [DipToken]
uParseDipMessage = listify . uMsg

idParse d = runIdentity (runErrorT (parseDipMessage 10 (uParseDipMessage d)))

stringyDip :: [DipToken] -> String
stringyDip toks = toks >>= (' ' :) . show

uTok :: a -> AppendList a
uTok a = (a :)

listify :: AppendList a -> [a]
listify = ($ [])

appendListify :: [a] -> AppendList a
appendListify = foldr (\a -> (uTok a .)) id

insertAt :: Int -> UnParser a a
insertAt 0 a l = a : l
insertAt n a (b : as) = b : insertAt (n - 1) a as
insertAt _ _ [] = undefined

uParen :: UnDipParser a -> UnDipParser a
uParen up a = uTok Bra . up a . uTok Ket

uMany :: UnDipParser a -> UnDipParser [a]
uMany up = foldl (.) id . map up

uPair :: UnDipParser a -> UnDipParser b -> UnDipParser (a, b)
uPair ua ub (a, b) = ua a . ub b

uMaybe :: UnDipParser a -> UnDipParser (Maybe a)
uMaybe up m = maybe id up m

uStr :: UnDipParser String
uStr = appendListify . map Character

uInt :: UnDipParser Int
uInt = uTok . DipInt

uMsg :: UnDipParser DipMessage
uMsg ms = case ms of
  Accept msg -> ( uTok (DipCmd YES)
                . uParen uMsg msg
                )

  Reject msg -> ( uTok (DipCmd REJ)
                . uParen uMsg msg
                )

  Cancel msg -> ( uTok (DipCmd NOT)
                . uParen uMsg msg
                )

  Name sName sVersion -> ( uTok (DipCmd NME)
                         . uParen uStr sName
                         . uParen uStr sVersion
                         )

  MapName sName -> ( uTok (DipCmd MAP)
                   . uParen uStr sName
                   )

  MapNameReq -> uTok (DipCmd MAP)

  Observer -> uTok (DipCmd OBS)

  Rejoin power passcode -> ( uTok (DipCmd IAM)
                           . uParen uPower power
                           . uParen uInt passcode
                           )

  MapDef (MapDefinition powers provinces (Adjacencies adjacencies) scos) ->
    ( uTok (DipCmd MDF)
      . uParen (uMany uPower) powers
      . uParen uProvinces (provinces, scos)
      . uParen (uMany (uParen uAdjacency)) (Map.toList adjacencies)
    )

  MapDefReq -> uTok (DipCmd MDF)

  Start pow passCode lvl variantOpts ->
    ( uTok (DipCmd HLO)
    . uParen uPower pow
    . uParen uInt passCode
    . uTok (DipParam LVL) . uInt lvl
    . uMany uVariantOpt variantOpts
    )

  StartPing -> uTok (DipCmd HLO)

  CurrentPosition (SupplyCOwnerships supplyCentres) ->
    ( uTok (DipCmd SCO)
    . uMany uSupplyCentre (Map.toList supplyCentres)
    )

  CurrentPositionReq -> uTok (DipCmd SCO)

  CurrentUnitPosition turn uPoss ->
    uTok (DipCmd NOW)
    . case uPoss of
      UnitPositions unitPoss -> ( uParen uTurn turn
                                  . uMany (uParen uUnitPosition) unitPoss
                                )
      UnitPositionsRet unitPoss -> uParen uTurn turn
                                   . uMany (uParen (uPair uUnitPosition
                                                    (\n -> ( uTok (DipParam MRT)
                                                             . uParen (uMany uProvinceNode) n
                                                           )))) unitPoss

  CurrentUnitPositionReq ->
    uTok (DipCmd NOW)

  HistoryReq turn ->
    ( uTok (DipCmd HST)
    . uParen uTurn turn
    )

  SubmitOrder mturn orders ->
    ( uTok (DipCmd SUB)
    . uMaybe (uParen uTurn) mturn
    . uMany (uParen uOrder) orders
    )

  AckOrder order orderNote ->
    ( uTok (DipCmd THX)
    . uParen uOrder order
    . uParen uOrderNote orderNote
    )

  Missing missing ->
    uTok (DipCmd MIS)
    . case missing of
      MissingMovement unitPoss -> uMany uUnitPosition unitPoss
      MissingRetreat unitPosRets -> uMany (uParen (uPair uUnitPosition
                                                   (\n -> ( uTok (DipParam MRT)
                                                          . uParen (uMany uProvinceNode) n
                                                          )))) unitPosRets
      MissingBuild n -> uParen uInt n

  MissingReq ->
    uTok (DipCmd MIS)

  StartProcessing ->
    uTok (DipCmd GOF)

  OrderResult turn order result ->
    ( uTok (DipCmd ORD)
    . uParen uTurn turn
    . uParen uOrder order
    . uParen uResult result
    )

  SaveGame gameName ->
    ( uTok (DipCmd SVE)
    . uParen uStr gameName
    )

  LoadGame gameName ->
    ( uTok (DipCmd LOD)
    . uParen uStr gameName
    )

  ExitClient ->
    uTok (DipCmd OFF)

  TimeUntilDeadline timeLeft ->
    ( uTok (DipCmd TME)
    . uParen uInt timeLeft
    )

  DipError (Paren message) ->
    ( uTok (DipCmd PRN)
    . uParen (uMany uTok) message
    )

  DipError (Syntax message) ->
    ( uTok (DipCmd HUH)
    . uParen (uMany uTok) message
    )

  DipError (CivilDisorder power) ->
    ( uTok (DipCmd CCD)
    . uParen uPower power
    )

  DipError (ParseError _) ->
    ( uTok (DipCmd HUH)
    . uParen (uMany uTok) []
    )

  AdminMessage name message ->
    ( uTok (DipCmd ADM)
    . uParen uStr name
    . uParen uStr message
    )

  SoloWinGame power ->
    ( uTok (DipCmd SLO)
    . uParen uPower power
    )

  DrawGame mPowers ->
    ( uTok (DipCmd DRW)
    . uMaybe (uMany (uParen uPower)) mPowers
    )

  SendPress mTurn (OutMessage powers pMessage) ->
    ( uTok (DipCmd SND)
    . uMaybe (uParen uTurn) mTurn
    . uParen (uMany uPower) powers
    . uParen uPressMessage pMessage
    )

  PowerEliminated power ->
    ( uTok (DipCmd OUT)
    . uParen uPower power
    )

  ReceivePress (InMessage fromPower toPowers msg) ->
    ( uTok (DipCmd FRM)
    . uParen uPower fromPower
    . uParen (uMany uPower) toPowers
    . uParen uPressMessage msg
    )

  EndGameStats turn playerStats ->
    ( uTok (DipCmd SMR)
    . uParen uTurn turn
    . uMany (uParen uPlayerStat) playerStats
    )

uPlayerStat :: UnDipParser PlayerStat
uPlayerStat (PlayerStat power name message centres yearOfElimination) =
  ( uPower power
  . uParen uStr name
  . uParen uStr message
  . uInt centres
  . uMaybe uInt yearOfElimination
  )


uPressMessage :: UnDipParser PressMessage
uPressMessage pm = case pm of
  PressProposal pressArr ->
    ( uTok (DipPress PRP)
    . uParen uPressArrangement pressArr
    )
  PressReply reply -> case reply of
    PressHuh msg ->
      ( uTok (DipCmd HUH)
      . uParen uPressMessage msg
      )
    PressAccept msg ->
      ( uTok (DipCmd YES)
      . uParen uPressMessage msg
      )
    PressReject msg ->
      ( uTok (DipCmd REJ)
      . uParen uPressMessage msg
      )
    PressRefuse msg ->
      ( uTok (DipPress BWX)
      . uParen uPressMessage msg
      )
    PressCancel msg ->
      ( uTok (DipPress CCL)
      . uParen uPressMessage msg
      )
  PressInfo arrangement ->
    ( uTok (DipPress FCT)
    . uParen uPressArrangement arrangement
    )
  PressCapable tks ->
    ( uTok (DipPress TRY)
    . uParen (uMany uTok) tks
    )

uPressArrangement arr = case arr of
  ArrangeDraw ->
    uTok (DipCmd DRW)
  ArrangeSolo power ->
    ( uTok (DipCmd SLO)
    . uParen uPower power
    )
  ArrangePeace powers ->
    ( uTok (DipPress PCE)
    . uParen (uMany uPower) powers
    )
  ArrangeAlliance allies enemies ->
    ( uTok (DipPress ALY)
    . uParen (uMany uPower) allies
    . uTok (DipPress VSS)
    . uParen (uMany uPower) enemies
    )
  ArrangeNot arrangement ->
    ( uTok (DipCmd NOT)
    . uPressArrangement arrangement
    )
  ArrangeUndo arrangement ->
    ( uTok (DipPress NAR)
    . uPressArrangement arrangement
    )

uResult :: UnDipParser OrderResult
uResult (Result normal retreat) =
  ( uMaybe uResultNormal normal
  . uMaybe uResultRetreat retreat
  )

uResultNormal :: UnDipParser ResultNormal
uResultNormal res = case res of
  Success -> uTok (DipResult SUC)
  MoveBounced -> uTok (DipResult BNC)
  SupportCut -> uTok (DipResult CUT)
  DisbandedConvoy -> uTok (DipResult DSR)
  NoSuchOrder -> uTok (DipResult NSO)

uResultRetreat :: UnDipParser ResultRetreat
uResultRetreat ResultRetreat =
  uTok (DipResult RET)

uOrder :: UnDipParser Order
uOrder (OrderBuild (Waive power)) =
  ( uPower power
  . uTok (DipOrder WVE)
  )
uOrder (OrderMovement (Hold unit)) =
  ( uParen uUnitPosition unit
  . uTok (DipOrder HLD)
  )
uOrder (OrderMovement (Move unit provinceNode)) =
  ( uParen uUnitPosition unit
  . uTok (DipOrder MTO)
  . uProvinceNode provinceNode
  )
uOrder (OrderMovement (SupportMove u1 u2 province)) =
  ( uParen uUnitPosition u1
  . uTok (DipOrder SUP)
  . uParen uUnitPosition u2
  . uTok (DipOrder MTO)
  . uProvince province
  )
uOrder (OrderMovement (SupportHold u1 u2)) =
  ( uParen uUnitPosition u1
  . uTok (DipOrder SUP)
  . uParen uUnitPosition u2
  )
uOrder (OrderMovement (Convoy u1 u2 provinceNode)) =
  ( uParen uUnitPosition u1
  . uTok (DipOrder CVY)
  . uParen uUnitPosition u2
  . uTok (DipOrder CTO)
  . uProvinceNode provinceNode
  )
uOrder (OrderMovement (MoveConvoy unit provinceNode provinces)) =
  ( uParen uUnitPosition unit
  . uTok (DipOrder CTO)
  . uProvinceNode provinceNode
  . uTok (DipOrder VIA)
  . uParen (uMany uProvince) provinces
  )
uOrder (OrderRetreat (Retreat unit provinceNode)) =
  ( uParen uUnitPosition unit
  . uTok (DipOrder RTO)
  . uProvinceNode provinceNode
  )
uOrder (OrderRetreat (Disband unit)) =
  ( uParen uUnitPosition unit
  . uTok (DipOrder DSB)
  )
uOrder (OrderBuild (Build unit)) =
  ( uParen uUnitPosition unit
  . uTok (DipOrder BLD)
  )
uOrder (OrderBuild (Remove unit)) =
  ( uParen uUnitPosition unit
  . uTok (DipOrder REM)
  )

uUnitPosition :: UnDipParser UnitPosition
uUnitPosition (UnitPosition pow typ provNode) =
  ( uPower pow
  . uUnitType typ
  . uProvinceNode provNode
  )

uOrderNote :: UnDipParser OrderNote
uOrderNote n = case n of
  MovementOK -> uTok (DipOrderNote MBV)
  NotAdjacent -> uTok (DipOrderNote FAR)
  NoSuchProvince -> uTok (DipOrderNote NSP)
  NoSuchUnit -> uTok (DipOrderNote NSU)
  NotAtSea -> uTok (DipOrderNote NAS)
  NoSuchFleet -> uTok (DipOrderNote NSF)
  NoSuchArmy -> uTok (DipOrderNote NSA)
  NotYourUnit -> uTok (DipOrderNote NYU)
  NoRetreatNeeded -> uTok (DipOrderNote NRN)
  InvalidRetreatSpace -> uTok (DipOrderNote NVR)
  NotYourSC -> uTok (DipOrderNote YSC)
  NotEmptySC -> uTok (DipOrderNote ESC)
  NotHomeSC -> uTok (DipOrderNote HSC)
  NotASC -> uTok (DipOrderNote NSC)
  InvalidBuildLocation -> uTok (DipOrderNote CST)
  NoMoreBuildAllowed -> uTok (DipOrderNote NMB)
  NoMoreRemovalAllowed -> uTok (DipOrderNote NMR)
  NotCurrentSeason -> uTok (DipOrderNote NRS)



uPower :: UnDipParser Power
uPower (Power p) = uTok (DipPow (Pow p))
uPower Neutral = uTok (DipParam UNO)

uProvinces :: UnDipParser ([Province], SupplyCOwnerships)
uProvinces (provs, (SupplyCOwnerships scos)) =
  let nscos = filter provinceIsSupply provs in
  ( uParen (uMany (uParen uSupplyCentre)) (Map.toList scos)
  . uParen (uMany uProvince) nscos
  )

uAdjacency :: UnDipParser (Province, [UnitToProv])
uAdjacency (province, unitToProvs) =
  ( uProvince province
  . uMany (uParen uUnitToProv) unitToProvs
  )

uUnitToProv :: UnDipParser UnitToProv
uUnitToProv (UnitToProv unitType provNodes) =
  ( uUnitType unitType
  . uMany uProvinceNode provNodes
  )
uUnitToProv (CoastalFleetToProv coast provNodes) =
  ( uParen (\c -> uTok (DipUnitType Fleet) . uCoast c) coast
  . uMany uProvinceNode provNodes
  )

uUnitType :: UnDipParser UnitType
uUnitType typ = uTok (DipUnitType typ)

uCoast :: UnDipParser Coast
uCoast c = uTok (DipCoast c)

uProvinceNode :: UnDipParser ProvinceNode
uProvinceNode (ProvNode prov) = uProvince prov
uProvinceNode (ProvCoastNode prov coast) =
  uParen (\c -> uProvince prov
         . uCoast c
         ) coast

uSupplyCentre :: UnDipParser (Power, [Province])
uSupplyCentre (pow, centres) =
  ( uPower pow
  . uMany uProvince centres
  )

uProvince :: UnDipParser Province
uProvince p = uTok (DipProv p)

uVariantOpt :: UnDipParser VariantOption
uVariantOpt (Level l)          = uTok (DipParam LVL) . uInt l
uVariantOpt (TimeMovement t)   = uTok (DipParam MTL) . uInt t
uVariantOpt (TimeRetreat t)    = uTok (DipParam RTL) . uInt t
uVariantOpt (TimeBuild t)      = uTok (DipParam BTL) . uInt t
uVariantOpt (DeadlineStop)     = uTok (DipParam DSD)
uVariantOpt (AnyOrderAccepted) = uTok (DipParam AOA)
uVariantOpt _ = undefined

uPhase :: UnDipParser Phase
uPhase p = uTok (DipPhase p)

uTurn :: UnDipParser Turn
uTurn (Turn p y) = uPhase p . uInt y

                   -- TESTING --



instance Arbitrary DipMessage where
  arbitrary = frequency [ (1, do
                              s1 <- arbitrary
                              s2 <- arbitrary
                              return (Name s1 s2))
                        , (1, return Observer)
                        , (1, do
                              p <- arbitrary
                              i <- arbitrary
                              return (Rejoin p i))
                        , (1, return . MapName =<< arbitrary)
                        , (1, return MapNameReq)
                        , (9, return . MapDef =<< arbitrary)
                          -- FINISH THIS
                        ]
