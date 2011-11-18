{-# LANGUAGE EmptyDataDecls #-}
module Diplomacy.Common.DipToken where

import Diplomacy.Common.DaideError
import Diplomacy.Common.Data as Dat

import Data.Binary
import Control.Exception
import Data.Bits
import Data.Char
import qualified Data.Map as Map

data DipToken = DipInt Int
              | Bra
              | Ket
              | DipPow Pow
              | DipUnitType UnitType
              | DipOrder OrderTok
              | DipOrderNote OrderNoteTok
              | DipResult ResultTok
              | DipCoast Dat.Coast
              | DipPhase Phase
              | DipCmd Cmd
              | DipParam Param
              | DipPress Press
              | Character Char
              | DipProv Bool Dat.ProvinceInter
              deriving (Eq)

instance Binary DipToken where
  put (DipInt int) = put . (.&. 0x3FFF) $ (fromIntegral int :: Word16)
  put (Bra) = put (0x40 :: Word8)
  put (Ket) = put (0x40 :: Word8)
  put (DipPow (Pow p)) = put (0x41 :: Word8) >> put (fromIntegral p :: Word8)
  put (DipUnitType Army) = put (0x42 :: Word8) >> put (0x00 :: Word8)
  put (DipUnitType Fleet) = put (0x42 :: Word8) >> put (0x01 :: Word8)
  put (DipOrder order) = put (0x43 :: Word8) >> putOrderTok order
  put (DipOrderNote orderNote) = put (0x44 :: Word8) >> putOrderNoteTok orderNote
  put (DipResult result) = put (0x45 :: Word8) >> putResult result
  put (DipCoast coast) = put (0x46 :: Word8) >> putCoast coast
  put (DipPhase phase) = put (0x47 :: Word8) >> putPhase phase
  put (DipCmd cmd) = put (0x48 :: Word8) >> putCmd cmd
  put (DipParam param) = put (0x49 :: Word8) >> putParam param
  put (DipPress press) = put (0x4A :: Word8) >> putPress press
  put (Character character) = put (0x4B :: Word8) >> putCharacter character
  put (DipProv isSupply (Inland prov)) = put (0x50 + (isSupply ? 0 $ 1) :: Word8) >> putProv prov
  put (DipProv isSupply (Sea prov)) = put (0x52 + (isSupply ? 0 $ 1) :: Word8) >> putProv prov
  put (DipProv isSupply (Coastal prov)) = put (0x54 + (isSupply ? 0 $ 1) :: Word8) >> putProv prov
  put (DipProv isSupply (BiCoastal prov)) = put (0x56 + (isSupply ? 0 $ 1) :: Word8) >> putProv prov

  get = do
    typ <- (get :: Get Word8)
    val <- (get :: Get Word8)
    decodeToken typ val

infixl 6 ?
(?) :: Bool -> a -> a -> a
(?) bool a b = if bool then a else b

instance Show DipToken where
  show t = case t of
    DipInt i -> show i
    Bra -> "("
    Ket -> ")"
    DipPow (Pow p) -> show p
    DipUnitType Army -> "ARM"
    DipUnitType Fleet -> "FLT"
    DipOrder o -> show o
    DipOrderNote n -> show n
    DipResult r -> show r
    DipCoast (Coast c) -> show c
    DipPhase p -> show p
    DipCmd c -> show c
    DipParam p -> show p
    DipPress p -> show p
    Character c -> [c]
    DipProv _ (Inland i) -> show i
    DipProv _ (Sea i) -> show i
    DipProv _ (Coastal i) -> show i
    DipProv _ (BiCoastal i) -> show i

data Pow = Pow Int
              deriving (Show, Eq)

data OrderTok = CTO
              | CVY
              | HLD
              | MTO
              | SUP
              | VIA
              | DSB
              | RTO
              | BLD
              | REM
              | WVE
              deriving (Show, Eq)

data OrderNoteTok = MBV
                  | BPR
                  | CST
                  | ESC
                  | FAR
                  | HSC
                  | NAS
                  | NMB
                  | NMR
                  | NRN
                  | NRS
                  | NSA
                  | NSC
                  | NSF
                  | NSP
                  | NST
                  | NSU
                  | NVR
                  | NYU
                  | YSC
                  deriving (Show, Eq)

data ResultTok = SUC
               | BNC
               | CUT
               | DSR
               | FLD
               | NSO
               | RET
               deriving (Show, Eq)

data Cmd = CCD
         | DRW
         | FRM
         | GOF
         | HLO
         | HST
         | HUH
         | IAM
         | LOD
         | MAP
         | MDF
         | MIS
         | NME
         | NOT
         | NOW
         | OBS
         | OFF
         | ORD
         | OUT
         | PRN
         | REJ
         | SCO
         | SLO
         | SND
         | SUB
         | SVE
         | THX
         | TME
         | YES
         | ADM
         | SMR
         deriving (Show, Eq)

data Param = AOA
           | BTL
           | ERR
           | LVL
           | MRT
           | MTL
           | NPB
           | NPR
           | PDA
           | PTL
           | RTL
           | UNO
           | DSD
              deriving (Show, Eq)

data Press = ALY
           | AND
           | BWX
           | DMZ
           | ELS
           | EXP
           | FWD
           | FCT
           | FOR
           | HOW
           | IDK
           | IFF
           | INS
           | IOU
           | OCC
           | ORR
           | PCE
           | POB
           | PPT
           | PRP
           | QRY
           | SCD
           | SRY
           | SUG
           | THK
           | THN
           | TRY
           | UOM
           | VSS
           | WHT
           | WHY
           | XDO
           | XOY
           | YDO
           | WRT
           | BCC
           | UNT
           | CCL
           | NAR
           deriving (Show, Eq)


decodeToken :: Word8 -> Word8 -> Get DipToken
decodeToken 0x40 0x00 = return Bra
decodeToken 0x40 0x01 = return Ket
decodeToken 0x41 val = return . DipPow . Pow . fromIntegral $ val
decodeToken 0x42 0x00 = return . DipUnitType $ Army
decodeToken 0x42 0x01 = return . DipUnitType $ Fleet
decodeToken 0x43 val = return . DipOrder . decodeOrderTok $ val
decodeToken 0x44 val = return . DipOrderNote . decodeOrderNoteTok $ val
decodeToken 0x45 val = return . DipResult . decodeResult $ val
decodeToken 0x46 val = return . DipCoast . Coast . fromIntegral $ val
decodeToken 0x47 val = return . DipPhase . decodePhase $ val
decodeToken 0x48 val = return . DipCmd . decodeCmd $ val
decodeToken 0x49 val = return . DipParam . decodeParam $ val
decodeToken 0x4A val = return . DipPress . decodePress $ val
decodeToken 0x4B val = return . Character . chr . fromIntegral $ val
decodeToken 0x50 val = return . DipProv False . Inland . fromIntegral $ val
decodeToken 0x51 val = return . DipProv True . Inland . fromIntegral $ val
decodeToken 0x52 val = return . DipProv False . Sea . fromIntegral $ val
decodeToken 0x53 val = return . DipProv True . Sea . fromIntegral $ val
decodeToken 0x54 val = return . DipProv False . Coastal . fromIntegral $ val
decodeToken 0x55 val = return . DipProv True . Coastal . fromIntegral $ val
decodeToken 0x56 val = return . DipProv False . BiCoastal . fromIntegral $ val
decodeToken 0x57 val = return . DipProv True . BiCoastal . fromIntegral $ val
decodeToken typ val
  | typ .&. 0xC0 == 0 = if typ .&. 0x20 == 0        -- if positive
                        then return . DipInt $ (fromIntegral typ :: Int) `shift` 8 + fromIntegral val
                        else return . DipInt . (-1 -) . (fromIntegral :: Word16 -> Int) . (0x1FFF .&.) . complement $ (fromIntegral (typ .&. 0x1F) :: Word16) `shift` 8 + fromIntegral val
  | otherwise = throw InvalidToken

decodeOrderTok 0x20 = CTO
decodeOrderTok 0x21 = CVY
decodeOrderTok 0x22 = HLD
decodeOrderTok 0x23 = MTO
decodeOrderTok 0x24 = SUP
decodeOrderTok 0x25 = VIA
decodeOrderTok 0x40 = DSB
decodeOrderTok 0x41 = RTO
decodeOrderTok 0x80 = BLD
decodeOrderTok 0x81 = REM
decodeOrderTok 0x82 = WVE
decodeOrderTok _ = throw InvalidToken

decodeOrderNoteTok 0x00 = MBV
decodeOrderNoteTok 0x01 = BPR
decodeOrderNoteTok 0x02 = CST
decodeOrderNoteTok 0x03 = ESC
decodeOrderNoteTok 0x04 = FAR
decodeOrderNoteTok 0x05 = HSC
decodeOrderNoteTok 0x06 = NAS
decodeOrderNoteTok 0x07 = NMB
decodeOrderNoteTok 0x08 = NMR
decodeOrderNoteTok 0x09 = NRN
decodeOrderNoteTok 0x0A = NRS
decodeOrderNoteTok 0x0B = NSA
decodeOrderNoteTok 0x0C = NSC
decodeOrderNoteTok 0x0D = NSF
decodeOrderNoteTok 0x0E = NSP
decodeOrderNoteTok 0x0F = NST
decodeOrderNoteTok 0x10 = NSU
decodeOrderNoteTok 0x11 = NVR
decodeOrderNoteTok 0x12 = NYU
decodeOrderNoteTok 0x13 = YSC
decodeOrderNoteTok _ = throw InvalidToken


decodeResult 0x00 = SUC
decodeResult 0x01 = BNC
decodeResult 0x02 = CUT
decodeResult 0x03 = DSR
decodeResult 0x04 = FLD
decodeResult 0x05 = NSO
decodeResult 0x06 = RET
decodeResult _ = throw InvalidToken

decodePhase 0x00 = Spring
decodePhase 0x01 = Summer
decodePhase 0x02 = Fall
decodePhase 0x03 = Autumn
decodePhase 0x04 = Winter
decodePhase _ = throw InvalidToken


decodeCmd 0x00 = CCD
decodeCmd 0x01 = DRW
decodeCmd 0x02 = FRM
decodeCmd 0x03 = GOF
decodeCmd 0x04 = HLO
decodeCmd 0x05 = HST
decodeCmd 0x06 = HUH
decodeCmd 0x07 = IAM
decodeCmd 0x08 = LOD
decodeCmd 0x09 = MAP
decodeCmd 0x0A = MDF
decodeCmd 0x0B = MIS
decodeCmd 0x0C = NME
decodeCmd 0x0D = NOT
decodeCmd 0x0E = NOW
decodeCmd 0x0F = OBS
decodeCmd 0x10 = OFF
decodeCmd 0x11 = ORD
decodeCmd 0x12 = OUT
decodeCmd 0x13 = PRN
decodeCmd 0x14 = REJ
decodeCmd 0x15 = SCO
decodeCmd 0x16 = SLO
decodeCmd 0x17 = SND
decodeCmd 0x18 = SUB
decodeCmd 0x19 = SVE
decodeCmd 0x1A = THX
decodeCmd 0x1B = TME
decodeCmd 0x1C = YES
decodeCmd 0x1D = ADM
decodeCmd 0x1E = SMR
decodeCmd _ = throw InvalidToken


decodeParam 0x00 = AOA
decodeParam 0x01 = BTL
decodeParam 0x02 = ERR
decodeParam 0x03 = LVL
decodeParam 0x04 = MRT
decodeParam 0x05 = MTL
decodeParam 0x06 = NPB
decodeParam 0x07 = NPR
decodeParam 0x08 = PDA
decodeParam 0x09 = PTL
decodeParam 0x0A = RTL
decodeParam 0x0B = UNO
decodeParam 0x0D = DSD
decodeParam _ = throw InvalidToken


decodePress 0x00 = ALY
decodePress 0x01 = AND
decodePress 0x02 = BWX
decodePress 0x03 = DMZ
decodePress 0x04 = ELS
decodePress 0x05 = EXP
decodePress 0x06 = FWD
decodePress 0x07 = FCT
decodePress 0x08 = FOR
decodePress 0x09 = HOW
decodePress 0x0A = IDK
decodePress 0x0B = IFF
decodePress 0x0C = INS
decodePress 0x0D = IOU
decodePress 0x0E = OCC
decodePress 0x0F = ORR
decodePress 0x10 = PCE
decodePress 0x11 = POB
decodePress 0x12 = PPT
decodePress 0x13 = PRP
decodePress 0x14 = QRY
decodePress 0x15 = SCD
decodePress 0x16 = SRY
decodePress 0x17 = SUG
decodePress 0x18 = THK
decodePress 0x19 = THN
decodePress 0x1A = TRY
decodePress 0x1B = UOM
decodePress 0x1C = VSS
decodePress 0x1D = WHT
decodePress 0x1E = WHY
decodePress 0x1F = XDO
decodePress 0x20 = XOY
decodePress 0x21 = YDO
decodePress 0x22 = WRT
decodePress 0x23 = BCC
decodePress 0x24 = UNT
decodePress 0x25 = CCL
decodePress 0x26 = NAR
decodePress _ = throw InvalidToken

putOrderTok CTO = put (0x20 :: Word8)
putOrderTok CVY = put (0x21 :: Word8)
putOrderTok HLD = put (0x22 :: Word8)
putOrderTok MTO = put (0x23 :: Word8)
putOrderTok SUP = put (0x24 :: Word8)
putOrderTok VIA = put (0x25 :: Word8)
putOrderTok DSB = put (0x40 :: Word8)
putOrderTok RTO = put (0x41 :: Word8)
putOrderTok BLD = put (0x80 :: Word8)
putOrderTok REM = put (0x81 :: Word8)
putOrderTok WVE = put (0x82 :: Word8)

putOrderNoteTok MBV = put (0x00 :: Word8)
putOrderNoteTok BPR = put (0x01 :: Word8)
putOrderNoteTok CST = put (0x02 :: Word8)
putOrderNoteTok ESC = put (0x03 :: Word8)
putOrderNoteTok FAR = put (0x04 :: Word8)
putOrderNoteTok HSC = put (0x05 :: Word8)
putOrderNoteTok NAS = put (0x06 :: Word8)
putOrderNoteTok NMB = put (0x07 :: Word8)
putOrderNoteTok NMR = put (0x08 :: Word8)
putOrderNoteTok NRN = put (0x09 :: Word8)
putOrderNoteTok NRS = put (0x0A :: Word8)
putOrderNoteTok NSA = put (0x0B :: Word8)
putOrderNoteTok NSC = put (0x0C :: Word8)
putOrderNoteTok NSF = put (0x0D :: Word8)
putOrderNoteTok NSP = put (0x0E :: Word8)
putOrderNoteTok NST = put (0x0F :: Word8)
putOrderNoteTok NSU = put (0x10 :: Word8)
putOrderNoteTok NVR = put (0x11 :: Word8)
putOrderNoteTok NYU = put (0x12 :: Word8)
putOrderNoteTok YSC = put (0x13 :: Word8)

putResult SUC = put (0x00 :: Word8)
putResult BNC = put (0x01 :: Word8)
putResult CUT = put (0x02 :: Word8)
putResult DSR = put (0x03 :: Word8)
putResult FLD = put (0x04 :: Word8)
putResult NSO = put (0x05 :: Word8)
putResult RET = put (0x06 :: Word8)

putPhase Spring = put (0x00 :: Word8)
putPhase Summer = put (0x01 :: Word8)
putPhase Fall = put (0x02 :: Word8)
putPhase Autumn = put (0x03 :: Word8)
putPhase Winter = put (0x04 :: Word8)

putCmd CCD = put (0x00 :: Word8)
putCmd DRW = put (0x01 :: Word8)
putCmd FRM = put (0x02 :: Word8)
putCmd GOF = put (0x03 :: Word8)
putCmd HLO = put (0x04 :: Word8)
putCmd HST = put (0x05 :: Word8)
putCmd HUH = put (0x06 :: Word8)
putCmd IAM = put (0x07 :: Word8)
putCmd LOD = put (0x08 :: Word8)
putCmd MAP = put (0x09 :: Word8)
putCmd MDF = put (0x0A :: Word8)
putCmd MIS = put (0x0B :: Word8)
putCmd NME = put (0x0C :: Word8)
putCmd NOT = put (0x0D :: Word8)
putCmd NOW = put (0x0E :: Word8)
putCmd OBS = put (0x0F :: Word8)
putCmd OFF = put (0x10 :: Word8)
putCmd ORD = put (0x11 :: Word8)
putCmd OUT = put (0x12 :: Word8)
putCmd PRN = put (0x13 :: Word8)
putCmd REJ = put (0x14 :: Word8)
putCmd SCO = put (0x15 :: Word8)
putCmd SLO = put (0x16 :: Word8)
putCmd SND = put (0x17 :: Word8)
putCmd SUB = put (0x18 :: Word8)
putCmd SVE = put (0x19 :: Word8)
putCmd THX = put (0x1A :: Word8)
putCmd TME = put (0x1B :: Word8)
putCmd YES = put (0x1C :: Word8)
putCmd ADM = put (0x1D :: Word8)
putCmd SMR = put (0x1E :: Word8)

putParam AOA = put (0x00 :: Word8)
putParam BTL = put (0x01 :: Word8)
putParam ERR = put (0x02 :: Word8)
putParam LVL = put (0x03 :: Word8)
putParam MRT = put (0x04 :: Word8)
putParam MTL = put (0x05 :: Word8)
putParam NPB = put (0x06 :: Word8)
putParam NPR = put (0x07 :: Word8)
putParam PDA = put (0x08 :: Word8)
putParam PTL = put (0x09 :: Word8)
putParam RTL = put (0x0A :: Word8)
putParam UNO = put (0x0B :: Word8)
putParam DSD = put (0x0D :: Word8)

putPress ALY = put (0x00 :: Word8)
putPress AND = put (0x01 :: Word8)
putPress BWX = put (0x02 :: Word8)
putPress DMZ = put (0x03 :: Word8)
putPress ELS = put (0x04 :: Word8)
putPress EXP = put (0x05 :: Word8)
putPress FWD = put (0x06 :: Word8)
putPress FCT = put (0x07 :: Word8)
putPress FOR = put (0x08 :: Word8)
putPress HOW = put (0x09 :: Word8)
putPress IDK = put (0x0A :: Word8)
putPress IFF = put (0x0B :: Word8)
putPress INS = put (0x0C :: Word8)
putPress IOU = put (0x0D :: Word8)
putPress OCC = put (0x0E :: Word8)
putPress ORR = put (0x0F :: Word8)
putPress PCE = put (0x10 :: Word8)
putPress POB = put (0x11 :: Word8)
putPress PPT = put (0x12 :: Word8)
putPress PRP = put (0x13 :: Word8)
putPress QRY = put (0x14 :: Word8)
putPress SCD = put (0x15 :: Word8)
putPress SRY = put (0x16 :: Word8)
putPress SUG = put (0x17 :: Word8)
putPress THK = put (0x18 :: Word8)
putPress THN = put (0x19 :: Word8)
putPress TRY = put (0x1A :: Word8)
putPress UOM = put (0x1B :: Word8)
putPress VSS = put (0x1C :: Word8)
putPress WHT = put (0x1D :: Word8)
putPress WHY = put (0x1E :: Word8)
putPress XDO = put (0x1F :: Word8)
putPress XOY = put (0x20 :: Word8)
putPress YDO = put (0x21 :: Word8)
putPress WRT = put (0x22 :: Word8)
putPress BCC = put (0x23 :: Word8)
putPress UNT = put (0x24 :: Word8)
putPress CCL = put (0x25 :: Word8)
putPress NAR = put (0x26 :: Word8)

putCoast (Coast c) = put (fromIntegral c :: Word8)

putCharacter c = put (fromIntegral (ord c) :: Word8) 

putProv prov = put (fromIntegral prov :: Word8)

type TokenMap = Map.Map [Char] DipToken

tokenMap :: TokenMap
tokenMap = foldl (flip $ uncurry Map.insert) Map.empty
                 [ ("CTO", DipOrder CTO)
                 , ("CVY", DipOrder CVY)
                 , ("HLD", DipOrder HLD)
                 , ("MTO", DipOrder MTO)
                 , ("SUP", DipOrder SUP)
                 , ("VIA", DipOrder VIA)
                 , ("DSB", DipOrder DSB)
                 , ("RTO", DipOrder RTO)
                 , ("BLD", DipOrder BLD)
                 , ("REM", DipOrder REM)
                 , ("WVE", DipOrder WVE)

                 , ("MBV", DipOrderNote MBV)
                 , ("BPR", DipOrderNote BPR)
                 , ("CST", DipOrderNote CST)
                 , ("ESC", DipOrderNote ESC)
                 , ("FAR", DipOrderNote FAR)
                 , ("HSC", DipOrderNote HSC)
                 , ("NAS", DipOrderNote NAS)
                 , ("NMB", DipOrderNote NMB)
                 , ("NMR", DipOrderNote NMR)
                 , ("NRN", DipOrderNote NRN)
                 , ("NRS", DipOrderNote NRS)
                 , ("NSA", DipOrderNote NSA)
                 , ("NSC", DipOrderNote NSC)
                 , ("NSF", DipOrderNote NSF)
                 , ("NSP", DipOrderNote NSP)
                 , ("NST", DipOrderNote NST)
                 , ("NSU", DipOrderNote NSU)
                 , ("NVR", DipOrderNote NVR)
                 , ("NYU", DipOrderNote NYU)
                 , ("YSC", DipOrderNote YSC)

                 , ("SUC", DipResult SUC)
                 , ("BNC", DipResult BNC)
                 , ("CUT", DipResult CUT)
                 , ("DSR", DipResult DSR)
                 , ("FLD", DipResult FLD)
                 , ("NSO", DipResult NSO)
                 , ("RET", DipResult RET)

                 , ("CCD", DipCmd CCD)
                 , ("DRW", DipCmd DRW)
                 , ("FRM", DipCmd FRM)
                 , ("GOF", DipCmd GOF)
                 , ("HLO", DipCmd HLO)
                 , ("HST", DipCmd HST)
                 , ("HUH", DipCmd HUH)
                 , ("IAM", DipCmd IAM)
                 , ("LOD", DipCmd LOD)
                 , ("MAP", DipCmd MAP)
                 , ("MDF", DipCmd MDF)
                 , ("MIS", DipCmd MIS)
                 , ("NME", DipCmd NME)
                 , ("NOT", DipCmd NOT)
                 , ("NOW", DipCmd NOW)
                 , ("OBS", DipCmd OBS)
                 , ("OFF", DipCmd OFF)
                 , ("ORD", DipCmd ORD)
                 , ("OUT", DipCmd OUT)
                 , ("PRN", DipCmd PRN)
                 , ("REJ", DipCmd REJ)
                 , ("SCO", DipCmd SCO)
                 , ("SLO", DipCmd SLO)
                 , ("SND", DipCmd SND)
                 , ("SUB", DipCmd SUB)
                 , ("SVE", DipCmd SVE)
                 , ("THX", DipCmd THX)
                 , ("TME", DipCmd TME)
                 , ("YES", DipCmd YES)
                 , ("ADM", DipCmd ADM)

                 , ("AOA", DipParam AOA)
                 , ("BTL", DipParam BTL)
                 , ("ERR", DipParam ERR)
                 , ("LVL", DipParam LVL)
                 , ("MRT", DipParam MRT)
                 , ("MTL", DipParam MTL)
                 , ("NPB", DipParam NPB)
                 , ("NPR", DipParam NPR)
                 , ("PDA", DipParam PDA)
                 , ("PTL", DipParam PTL)
                 , ("RTL", DipParam RTL)
                 , ("UNO", DipParam UNO)
                 , ("DSD", DipParam DSD)

                 , ("ALY", DipPress ALY)
                 , ("AND", DipPress AND)
                 , ("BWX", DipPress BWX)
                 , ("DMZ", DipPress DMZ)
                 , ("ELS", DipPress ELS)
                 , ("EXP", DipPress EXP)
                 , ("FWD", DipPress FWD)
                 , ("FCT", DipPress FCT)
                 , ("FOR", DipPress FOR)
                 , ("HOW", DipPress HOW)
                 , ("IDK", DipPress IDK)
                 , ("IFF", DipPress IFF)
                 , ("INS", DipPress INS)
                 , ("IOU", DipPress IOU)
                 , ("OCC", DipPress OCC)
                 , ("ORR", DipPress ORR)
                 , ("PCE", DipPress PCE)
                 , ("POB", DipPress POB)
                 , ("PPT", DipPress PPT)
                 , ("PRP", DipPress PRP)
                 , ("QRY", DipPress QRY)
                 , ("SCD", DipPress SCD)
                 , ("SRY", DipPress SRY)
                 , ("SUG", DipPress SUG)
                 , ("THK", DipPress THK)
                 , ("THN", DipPress THN)
                 , ("TRY", DipPress TRY)
                 , ("UOM", DipPress UOM)
                 , ("VSS", DipPress VSS)
                 , ("WHT", DipPress WHT)
                 , ("WHY", DipPress WHY)
                 , ("XDO", DipPress XDO)
                 , ("XOY", DipPress XOY)
                 , ("YDO", DipPress YDO)
                 , ("WRT", DipPress WRT)

                 , ("AMY", DipUnitType Army)
                 , ("FLT", DipUnitType Fleet)

                   -- standard map
                   -- provinces
                 , ("BOH", DipProv False (Inland 0x00))
                 , ("BUR", DipProv False (Inland 0x01))
                 , ("GAL", DipProv False (Inland 0x02))
                 , ("RUH", DipProv False (Inland 0x03))
                 , ("SIL", DipProv False (Inland 0x04))
                 , ("TYR", DipProv False (Inland 0x05))
                 , ("UKR", DipProv False (Inland 0x06))
                   
                 , ("BUD", DipProv True (Inland 0x07))
                 , ("MOS", DipProv True (Inland 0x08))
                 , ("MUN", DipProv True (Inland 0x09))
                 , ("PAR", DipProv True (Inland 0x0A))
                 , ("SER", DipProv True (Inland 0x0B))
                 , ("VIE", DipProv True (Inland 0x0C))
                 , ("WAR", DipProv True (Inland 0x0D))

                 , ("ADR", DipProv False (Sea 0x0E))
                 , ("AEG", DipProv False (Sea 0x0F))
                 , ("BAL", DipProv False (Sea 0x10))
                 , ("BAR", DipProv False (Sea 0x11))
                 , ("BLA", DipProv False (Sea 0x12))
                 , ("EAS", DipProv False (Sea 0x13))
                 , ("ECH", DipProv False (Sea 0x14))
                 , ("GOB", DipProv False (Sea 0x15))
                 , ("GOL", DipProv False (Sea 0x16))
                 , ("HEL", DipProv False (Sea 0x17))
                 , ("ION", DipProv False (Sea 0x18))
                 , ("IRI", DipProv False (Sea 0x19))
                 , ("MAO", DipProv False (Sea 0x1A))
                 , ("NAO", DipProv False (Sea 0x1B))
                 , ("NTH", DipProv False (Sea 0x1C))
                 , ("NWG", DipProv False (Sea 0x1D))
                 , ("SKA", DipProv False (Sea 0x1E))
                 , ("TYS", DipProv False (Sea 0x1F))
                 , ("WES", DipProv False (Sea 0x20))

                 , ("ALB", DipProv False (Coastal 0x21))
                 , ("APU", DipProv False (Coastal 0x22))
                 , ("ARM", DipProv False (Coastal 0x23))
                 , ("CLY", DipProv False (Coastal 0x24))
                 , ("FIN", DipProv False (Coastal 0x25))
                 , ("GAS", DipProv False (Coastal 0x26))
                 , ("LVN", DipProv False (Coastal 0x27))
                 , ("NAF", DipProv False (Coastal 0x28))
                 , ("PIC", DipProv False (Coastal 0x29))
                 , ("PIE", DipProv False (Coastal 0x2A))
                 , ("PRU", DipProv False (Coastal 0x2B))
                 , ("SYR", DipProv False (Coastal 0x2C))
                 , ("TUS", DipProv False (Coastal 0x2D))
                 , ("WAL", DipProv False (Coastal 0x2E))
                 , ("YOR", DipProv False (Coastal 0x2F))
                   
                 , ("ANK", DipProv True (Coastal 0x30))
                 , ("BEL", DipProv True (Coastal 0x31))
                 , ("BER", DipProv True (Coastal 0x32))
                 , ("BRE", DipProv True (Coastal 0x33))
                 , ("CON", DipProv True (Coastal 0x34))
                 , ("DEN", DipProv True (Coastal 0x35))
                 , ("EDI", DipProv True (Coastal 0x36))
                 , ("GRE", DipProv True (Coastal 0x37))
                 , ("HOL", DipProv True (Coastal 0x38))
                 , ("KIE", DipProv True (Coastal 0x39))
                 , ("LON", DipProv True (Coastal 0x3A))
                 , ("LVP", DipProv True (Coastal 0x3B))
                 , ("MAR", DipProv True (Coastal 0x3C))
                 , ("NAP", DipProv True (Coastal 0x3D))
                 , ("NWY", DipProv True (Coastal 0x3E))
                 , ("POR", DipProv True (Coastal 0x3F))
                 , ("ROM", DipProv True (Coastal 0x40))
                 , ("RUM", DipProv True (Coastal 0x41))
                 , ("SEV", DipProv True (Coastal 0x42))
                 , ("SMY", DipProv True (Coastal 0x43))
                 , ("SWE", DipProv True (Coastal 0x44))
                 , ("TRI", DipProv True (Coastal 0x45))
                 , ("TUN", DipProv True (Coastal 0x46))
                 , ("VEN", DipProv True (Coastal 0x47))

                 , ("BUL", DipProv True (BiCoastal 0x48))
                 , ("SPA", DipProv True (BiCoastal 0x49))
                 , ("STP", DipProv True (BiCoastal 0x4A))

                   -- coasts
                 , ("NCS", DipCoast (Coast 0x00))
                 , ("NEC", DipCoast (Coast 0x02))
                 , ("ECS", DipCoast (Coast 0x04))
                 , ("SEC", DipCoast (Coast 0x06))
                 , ("SCS", DipCoast (Coast 0x08))
                 , ("SWC", DipCoast (Coast 0x0A))
                 , ("WCS", DipCoast (Coast 0x0C))
                 , ("NWC", DipCoast (Coast 0x0E))

                   -- powers
                 , ("AUS", DipPow (Pow 0x00))
                 , ("ENG", DipPow (Pow 0x01))
                 , ("FRA", DipPow (Pow 0x02))
                 , ("GER", DipPow (Pow 0x03))
                 , ("ITA", DipPow (Pow 0x04))
                 , ("RUS", DipPow (Pow 0x05))
                 , ("TUR", DipPow (Pow 0x06))
                 ]
