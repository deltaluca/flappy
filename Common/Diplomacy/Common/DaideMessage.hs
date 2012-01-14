{-# LANGUAGE DeriveDataTypeable, FlexibleInstances #-}
-- |this module defines the low level daidemessages (diplomacy messages are a subset)
module Diplomacy.Common.DaideMessage where

import Diplomacy.Common.DaideError
import Diplomacy.Common.DipMessage
import Diplomacy.Common.DipToken

--import Debug.Trace
import Data.Serialize
import Data.Word
import Control.Exception as E
import Control.Monad
import Control.Monad.Error
import Control.DeepSeq

data DaideMessage = IM {imVersion :: Int}
                  | RM
                  | FM
                  | DM DipMessage
                  | EM DaideError
                  deriving (Show)

instance NFData DaideMessage

_DAIDE_MAGIC_NUM    = 0xDA10 :: Word16
_DAIDE_MAGIC_NUM_LE = 0x10DA :: Word16
_DAIDE_VERSION = 1 :: Word16
_DAIDE_PRESS_LEVEL = 0

instance Serialize DaideMessage where
  put (IM version) = putMessage 0 4 $ do
    put (fromIntegral version :: Word16)
    put _DAIDE_MAGIC_NUM
  put RM = putMessage 1 0 $ return ()
  put (EM err) = putMessage 4 2 $ do
    (put :: Word16 -> Put) . fromIntegral . errorCode $ err
  put FM = putMessage 3 0 $ return ()
  put (DM dm) = do
    let toks = uParseDipMessage dm
    putMessage 2 (fromIntegral (length toks * 2)) (mapM_ put toks)
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
  when (version /= _DAIDE_VERSION) (E.throw VersionIncomp)
  when (magic /= _DAIDE_MAGIC_NUM)
    (do when (magic == _DAIDE_MAGIC_NUM_LE) (E.throw WrongMagic)
        E.throw WrongEndian)
  return . IM . fromIntegral $ version
daideMessage 1 _ = return RM
daideMessage 2 size = do
  when (size < 2) (E.throw MsgTooShort)
  tokens <- replicateM (fromIntegral size `div` 2) (get :: Get DipToken)
  eMessage <- runErrorT . parseDipMessage _DAIDE_PRESS_LEVEL $ tokens
  case eMessage of
    Left err -> throw err
    Right msg -> return (DM msg)
daideMessage 3 _ = return FM
daideMessage 4 size = do
  when (size < 2) (E.throw MsgTooShort)
  errCode <- get :: Get Word16
  return . EM . errorFromCode . fromIntegral $ errCode
daideMessage _ _ = E.throw UnknownMsg
