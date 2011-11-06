{-# LANGUAGE DeriveDataTypeable #-}

module Diplomacy.Common.DaideMessage where

import Diplomacy.Common.DaideError
import Diplomacy.Common.DipMessage
import Diplomacy.Common.DipToken

import Data.Binary
import Control.Exception as E
import Control.Monad
import Control.Monad.Error

data DaideMessage = IM {imVersion :: Int}
                  | RM
                  | FM
                  | DM DipMessage
                  | EM DaideError
                  | Tokens [DipToken] -- for debugging
                  deriving (Show)


_MAGIC_NUM    = 0xDA10 :: Word16
_MAGIC_NUM_LE = 0x10DA :: Word16
_VERSION = 1 :: Word16
_PRESS_LEVEL = 0

instance Binary DaideMessage where
  put (IM version) = putMessage 0 4 $ do
    put (fromIntegral version :: Word16)
    put _MAGIC_NUM
  put RM = putMessage 1 0 $ return ()
  put (EM err) = putMessage 4 2 $ do
    (put :: Word16 -> Put) . fromIntegral . errorCode $ err
  put FM = putMessage 3 0 $ return ()
  put _ = undefined
  get = do
    typ <- get :: Get Word8
    get :: Get Word8           -- padding
    size <- get :: Get Word16
    daideMessage typ size    

putMessage :: Word8 -> Word16 -> Put -> Put
putMessage typ lth dat = do
  put typ
  put (0 :: Word8)
  put lth
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
daideMessage 1 _ = return RM
daideMessage 2 size = do
  when (size < 2) (E.throw MsgTooShort)
  tokens <- replicateM (fromIntegral size `div` 2) (get :: Get DipToken)
  eMessage <- runErrorT . parseDipMessage _PRESS_LEVEL $ tokens
  case eMessage of
    Left err -> throw err
    Right msg -> return (DM msg)

daideMessage 3 _ = return FM
daideMessage 4 size = do
  when (size < 2) (E.throw MsgTooShort)
  E.throw UnknownMsg
daideMessage _ _ = E.throw UnknownMsg
