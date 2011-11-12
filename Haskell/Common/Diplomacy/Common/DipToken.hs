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
              | DipProv Dat.Province
              deriving (Eq)

instance Binary DipToken where
  put (DipInt int) = put . (.&. 0x3FFF) $ (fromIntegral int :: Word16)
  put _ = undefined
  get = do
    typ <- (get :: Get Word8)
    val <- (get :: Get Word8)
    decodeToken typ val

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
    DipProv (Inland i) -> show i
    DipProv (Sea i) -> show i
    DipProv (Coastal i) -> show i
    DipProv (BiCoastal i) -> show i

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
decodeToken 0x50 val = return . DipProv . Inland . fromIntegral $ val
decodeToken 0x51 val = return . DipProv . Inland . fromIntegral $ val
decodeToken 0x52 val = return . DipProv . Sea . fromIntegral $ val
decodeToken 0x53 val = return . DipProv . Sea . fromIntegral $ val
decodeToken 0x54 val = return . DipProv . Coastal . fromIntegral $ val
decodeToken 0x55 val = return . DipProv . Coastal . fromIntegral $ val
decodeToken 0x56 val = return . DipProv . BiCoastal . fromIntegral $ val
decodeToken 0x57 val = return . DipProv . BiCoastal . fromIntegral $ val
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
                 , ("BOH", DipProv (Inland 0x00))
                 , ("BUR", DipProv (Inland 0x01))
                 , ("GAL", DipProv (Inland 0x02))
                 , ("RUH", DipProv (Inland 0x03))
                 , ("SIL", DipProv (Inland 0x04))
                 , ("TYR", DipProv (Inland 0x05))
                 , ("UKR", DipProv (Inland 0x06))
                 , ("BUD", DipProv (Inland 0x07))
                 , ("MOS", DipProv (Inland 0x08))
                 , ("MUN", DipProv (Inland 0x09))
                 , ("PAR", DipProv (Inland 0x0A))
                 , ("SER", DipProv (Inland 0x0B))
                 , ("VIE", DipProv (Inland 0x0C))
                 , ("WAR", DipProv (Inland 0x0D))

                 , ("ADR", DipProv (Sea 0x0E))
                 , ("AEG", DipProv (Sea 0x0F))
                 , ("BAL", DipProv (Sea 0x10))
                 , ("BAR", DipProv (Sea 0x11))
                 , ("BLA", DipProv (Sea 0x12))
                 , ("EAS", DipProv (Sea 0x13))
                 , ("ECH", DipProv (Sea 0x14))
                 , ("GOB", DipProv (Sea 0x15))
                 , ("GOL", DipProv (Sea 0x16))
                 , ("HEL", DipProv (Sea 0x17))
                 , ("ION", DipProv (Sea 0x18))
                 , ("IRI", DipProv (Sea 0x19))
                 , ("MAO", DipProv (Sea 0x1A))
                 , ("NAO", DipProv (Sea 0x1B))
                 , ("NTH", DipProv (Sea 0x1C))
                 , ("NWG", DipProv (Sea 0x1D))
                 , ("SKA", DipProv (Sea 0x1E))
                 , ("TYS", DipProv (Sea 0x1F))
                 , ("WES", DipProv (Sea 0x20))

                 , ("ALB", DipProv (Coastal 0x21))
                 , ("APU", DipProv (Coastal 0x22))
                 , ("ARM", DipProv (Coastal 0x23))
                 , ("CLY", DipProv (Coastal 0x24))
                 , ("FIN", DipProv (Coastal 0x25))
                 , ("GAS", DipProv (Coastal 0x26))
                 , ("LVN", DipProv (Coastal 0x27))
                 , ("NAF", DipProv (Coastal 0x28))
                 , ("PIC", DipProv (Coastal 0x29))
                 , ("PIE", DipProv (Coastal 0x2A))
                 , ("PRU", DipProv (Coastal 0x2B))
                 , ("SYR", DipProv (Coastal 0x2C))
                 , ("TUS", DipProv (Coastal 0x2D))
                 , ("WAL", DipProv (Coastal 0x2E))
                 , ("YOR", DipProv (Coastal 0x2F))
                 , ("ANK", DipProv (Coastal 0x30))
                 , ("BEL", DipProv (Coastal 0x31))
                 , ("BER", DipProv (Coastal 0x32))
                 , ("BRE", DipProv (Coastal 0x33))
                 , ("CON", DipProv (Coastal 0x34))
                 , ("DEN", DipProv (Coastal 0x35))
                 , ("EDI", DipProv (Coastal 0x36))
                 , ("GRE", DipProv (Coastal 0x37))
                 , ("HOL", DipProv (Coastal 0x38))
                 , ("KIE", DipProv (Coastal 0x39))
                 , ("LON", DipProv (Coastal 0x3A))
                 , ("LVP", DipProv (Coastal 0x3B))
                 , ("MAR", DipProv (Coastal 0x3C))
                 , ("NAP", DipProv (Coastal 0x3D))
                 , ("NWY", DipProv (Coastal 0x3E))
                 , ("POR", DipProv (Coastal 0x3F))
                 , ("ROM", DipProv (Coastal 0x40))
                 , ("RUM", DipProv (Coastal 0x41))
                 , ("SEV", DipProv (Coastal 0x42))
                 , ("SMY", DipProv (Coastal 0x43))
                 , ("SWE", DipProv (Coastal 0x44))
                 , ("TRI", DipProv (Coastal 0x45))
                 , ("TUN", DipProv (Coastal 0x46))
                 , ("VEN", DipProv (Coastal 0x47))

                 , ("BUL", DipProv (BiCoastal 0x48))
                 , ("SPA", DipProv (BiCoastal 0x49))
                 , ("STP", DipProv (BiCoastal 0x4A))

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
