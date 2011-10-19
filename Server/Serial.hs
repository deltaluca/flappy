{-# LANGUAGE DeriveDataTypeable #-}

module Serial (DaideMessage(IM, RM, EM),
               DaideParseException(WrongMagicNumber),
               DaideError(TimerPopped,
                          UnknownMessage,
                          WrongMagic),
               daideDeserialise,
               daideSerialise) where

import Control.Exception
import Control.Monad
import Data.Binary
import Data.Typeable
import Data.ByteString.Lazy as L

data DaideMessage = IM {version :: Word16}
                   | RM
                   | EM DaideError
                   deriving (Show)
                     
data DaideError = TimerPopped
                | NoIM
                | WrongEndian
                | WrongMagic
                | VersionIncompatibility
                | ManyIMs
                | IMFromServer
                | UnknownMessage
                | MessageTooShort
                | DMBeforeRM
                | RMNotFirstFromServer
                | ManyRMs
                | RMFromClient
                | InvalidTokenInDM
                deriving (Show)

data DaideParseException = UnknownMessageType Word8
                    | WrongMagicNumber Word16
                      deriving (Show, Typeable)

instance Exception DaideParseException

daideDeserialise :: L.ByteString -> DaideMessage
daideDeserialise = decode

daideSerialise :: DaideMessage -> L.ByteString
daideSerialise = encode



_MAGIC_NUM = 0xDA10 :: Word16


instance Binary DaideMessage where
  put (IM version) = putMessage 0 4 $ do
    put (version :: Word16)
    put _MAGIC_NUM
  put RM = putMessage 1 0 $ return ()
  get = do
    typ <- get :: Get Word8
    get :: Get Word8           -- padding
    size <- get :: Get Word16
    daideMessage typ size    

putMessage :: Word8 -> Word16 -> Put -> Put
putMessage typ length dat = do
  put typ
  put (0 :: Word8)
  put length
  dat

daideMessage :: Word8 -> Word16 -> Get DaideMessage
daideMessage 0 size = do
  version <- get :: Get Word16
  magic <- get :: Get Word16
  if size == 4 && magic == _MAGIC_NUM
    then return (IM version)
    else throw (WrongMagicNumber magic)
daideMessage 1 size = do
  replicateM_ (fromIntegral size) (get :: Get Word8)
  return RM
daideMessage unknown _ = throw (UnknownMessageType unknown)


