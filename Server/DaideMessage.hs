{-# LANGUAGE DeriveDataTypeable #-}

module DaideMessage where

import DaideError
import DiplomacyMessage

import Data.Binary
import Data.Typeable
import Control.Exception as E
import Control.Monad

data DaideMessage = IM {version :: Int}
                  | RM
                  | FM
                  | DM DiplomacyMessage
                  | EM DaideError
                  | Tokens [DipToken]
                  deriving (Show)


_MAGIC_NUM    = 0xDA10 :: Word16
_MAGIC_NUM_LE = 0x10DA :: Word16
_VERSION = 1 :: Word16

instance Binary DaideMessage where
  put (IM version) = putMessage 0 4 $ do
    put (fromIntegral version :: Word16)
    put _MAGIC_NUM
  put RM = putMessage 1 0 $ return ()
  put (EM error) = putMessage 4 2 $ do
    (put :: Word16 -> Put) . fromIntegral . errorCode $ error
  put FM = putMessage 3 0 $ return ()
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
  when (size < 4) (E.throw MsgTooShort)
  version <- get :: Get Word16
  magic <- get :: Get Word16
  when (version /= _VERSION) (E.throw VersionIncomp)
  when (magic /= _MAGIC_NUM)
    (do when (magic == _MAGIC_NUM_LE) (E.throw WrongMagic)
        E.throw WrongEndian)
  return . IM . fromIntegral $ version
daideMessage 1 size = return RM
daideMessage 2 size = do
  when (size < 2) (E.throw MsgTooShort)
  tokens <- replicateM (fromIntegral size `div` 2) (get :: Get DipToken)
  return (Tokens tokens) -- DM . parseDipMessage $ tokens
daideMessage 3 size = return FM
daideMessage 4 size = do
  when (size < 2) (E.throw MsgTooShort)
  E.throw UnknownMsg
daideMessage unknown _ = E.throw UnknownMsg
