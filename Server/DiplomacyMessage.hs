{-# LANGUAGE EmptyDataDecls #-}
module DiplomacyMessage where

import DaideError

import Data.Binary
import Control.Exception
import Control.Monad
import Data.Bits
import Data.Char

data DiplomacyMessage = Lol
     deriving (Show)

parseDipMessage :: [DipToken] -> DiplomacyMessage
parseDipMessage = undefined

data DipToken = DipInt Int
              | Bra
              | Ket
              | DipPower Power
              | DipUnitType UnitType
              | DipOrder Order
              | DipOrderNote OrderNote
              | DipResult Result
              | DipCoast Coast
              | DipPhase Phase
              | DipCommand Command
              | DipParam Param
              | DipPress Press
              | Character Char
              | DipProv Prov

instance Binary DipToken where
  put (DipInt int) = do
    put (int .&. 0x3F)
  get = do
    typ <- (get :: Get Word8)
    val <- (get :: Get Word8)
    decodeToken typ val


data Power = Power Int
data UnitType = Army | Fleet
data Order = CTO
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

data Result = SUC
            | BNC
            | CUT
            | DSR
            | FLD
            | NSO
            | RET

data Coast = Coast Int

data Phase = SPR
           | SUM
           | FAL
           | AUT
           | WIN

data Command = CCD
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
             
data Prov = Inland Int
          | Sea Int
          | Coastal Int
          | BiCoastal Int

prov :: Int -> Prov
prov = undefined

decodeToken :: Word8 -> Word8 -> Get DipToken
decodeToken 0x40 0x00 = return Bra
decodeToken 0x40 0x01 = return Ket
decodeToken 0x41 val = return . DipPower . Power . fromIntegral $ val
decodeToken 0x42 0x00 = return . DipUnitType $ Army
decodeToken 0x42 0x01 = return . DipUnitType $ Fleet
decodeToken 0x43 val = return . DipOrder . decodeOrder $ val
decodeToken 0x44 val = return . DipOrderNote . decodeOrderNote $ val
decodeToken 0x45 val = return . DipResult . decodeResult $ val
decodeToken 0x46 val = return . DipCoast . Coast . fromIntegral $ val
decodeToken 0x47 val = return . DipPhase . decodePhase $ val
decodeToken 0x48 val = return . DipCommand . decodeCommand $ val
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
  | typ .&. 0xA0 == 0 = return . DipInt $ (fromIntegral typ :: Int) `shift` 8 + fromIntegral val
  | otherwise = throw InvalidToken

decodeOrder 0x20 = CTO
decodeOrder 0x21 = CVY
decodeOrder 0x22 = HLD
decodeOrder 0x23 = MTO
decodeOrder 0x24 = SUP
decodeOrder 0x25 = VIA
decodeOrder 0x40 = DSB
decodeOrder 0x41 = RTO
decodeOrder 0x80 = BLD
decodeOrder 0x81 = REM
decodeOrder 0x82 = WVE

decodeOrderNote 0x00 = MBV
decodeOrderNote 0x01 = BPR
decodeOrderNote 0x02 = CST
decodeOrderNote 0x03 = ESC
decodeOrderNote 0x04 = FAR
decodeOrderNote 0x05 = HSC
decodeOrderNote 0x06 = NAS
decodeOrderNote 0x07 = NMB
decodeOrderNote 0x08 = NMR
decodeOrderNote 0x09 = NRN
decodeOrderNote 0x0A = NRS
decodeOrderNote 0x0B = NSA
decodeOrderNote 0x0C = NSC
decodeOrderNote 0x0D = NSF
decodeOrderNote 0x0E = NSP
decodeOrderNote 0x0F = NST
decodeOrderNote 0x10 = NSU
decodeOrderNote 0x11 = NVR
decodeOrderNote 0x12 = NYU
decodeOrderNote 0x13 = YSC


decodeResult 0x00 = SUC
decodeResult 0x01 = BNC
decodeResult 0x02 = CUT
decodeResult 0x03 = DSR
decodeResult 0x04 = FLD
decodeResult 0x05 = NSO
decodeResult 0x06 = RET

decodePhase 0x00 = SPR
decodePhase 0x01 = SUM
decodePhase 0x02 = FAL
decodePhase 0x03 = AUT
decodePhase 0x04 = WIN


decodeCommand 0x00 = CCD
decodeCommand 0x01 = DRW
decodeCommand 0x02 = FRM
decodeCommand 0x03 = GOF
decodeCommand 0x04 = HLO
decodeCommand 0x05 = HST
decodeCommand 0x06 = HUH
decodeCommand 0x07 = IAM
decodeCommand 0x08 = LOD
decodeCommand 0x09 = MAP
decodeCommand 0x0A = MDF
decodeCommand 0x0B = MIS
decodeCommand 0x0C = NME
decodeCommand 0x0D = NOT
decodeCommand 0x0E = NOW
decodeCommand 0x0F = OBS
decodeCommand 0x10 = OFF
decodeCommand 0x11 = ORD
decodeCommand 0x12 = OUT
decodeCommand 0x13 = PRN
decodeCommand 0x14 = REJ
decodeCommand 0x15 = SCO
decodeCommand 0x16 = SLO
decodeCommand 0x17 = SND
decodeCommand 0x18 = SUB
decodeCommand 0x19 = SVE
decodeCommand 0x1A = THX
decodeCommand 0x1B = TME
decodeCommand 0x1C = YES
decodeCommand 0x1D = ADM


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
