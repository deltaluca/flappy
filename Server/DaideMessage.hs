{-# LANGUAGE DeriveDataTypeable #-}

module DaideMessage where

import DaideError

import Data.Binary
import Data.Typeable
import Control.Exception
import Control.Monad

data DaideMessage = IM {version :: Int}
                   | RM
                   | EM DaideError
                   deriving (Show)


_MAGIC_NUM    = 0xDA10 :: Word16
_MAGIC_NUM_LE = 0x10DA :: Word16

instance Binary DaideMessage where
  put (IM version) = putMessage 0 4 $ do
    put (fromIntegral version :: Word16)
    put _MAGIC_NUM
  put RM = putMessage 1 0 $ return ()
  put (EM error) = putMessage 4 2 $ do
    (put :: Word16 -> Put) . fromIntegral . errorCode $ error
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
    then return (IM (fromIntegral version))
    else if magic == _MAGIC_NUM_LE
         then throw WrongEndian
         else throw WrongMagic
daideMessage 1 size = do
  replicateM_ (fromIntegral size) (get :: Get Word8)
  return RM
daideMessage unknown _ = throw UnknownMsg
