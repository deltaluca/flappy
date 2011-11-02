{-# LANGUAGE EmptyDataDecls #-}
module DiplomacyToken where

import DaideError
import DiplomacyData as Dat

import Data.Binary
import Control.Exception
import Control.Monad
import Data.Bits
import Data.Char

data DipToken = DipInt Int
              | Bra
              | Ket
              | DipPow Pow
              | DipUnitType UnitType
              | DipOrder OrderTok
              | DipOrderNote OrderNoteTok
              | DipResult Result
              | DipCoast Dat.Coast
              | DipPhase Phase
              | DipCmd Cmd
              | DipParam Param
              | DipPress Press
              | Character Char
              | DipProv Dat.Province
              deriving (Show, Eq)

instance Binary DipToken where
  put (DipInt int) = put . (.&. 0x3FFF) $ (fromIntegral int :: Word16)
  get = do
    typ <- (get :: Get Word8)
    val <- (get :: Get Word8)
    decodeToken typ val


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

data OrderNote = MBV
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

data Result = SUC
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
              deriving (Show, Eq)             


decodeToken :: Word8 -> Word8 -> Get DipToken
decodeToken 0x40 0x00 = return Bra
decodeToken 0x40 0x01 = return Ket
decodeToken 0x41 val = return . DipPow . Pow . fromIntegral $ val
decodeToken 0x42 0x00 = return . DipUnitType $ Army
decodeToken 0x42 0x01 = return . DipUnitType $ Fleet
decodeToken 0x43 val = return . DipOrder . decodeOrderTok $ val
decodeToken 0x44 val = return . DipOrderNoteTok . decodeOrderNoteTok $ val
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
decodePress _ = throw InvalidToken
