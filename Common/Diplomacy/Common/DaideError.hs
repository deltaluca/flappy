{-# LANGUAGE DeriveDataTypeable, FlexibleInstances #-}
module Diplomacy.Common.DaideError( DaideError(..)
                                  , DaideErrorClass(..)
                                  , errorCode
                                  , errorFromCode ) where

import Control.Monad.Error
import Control.Exception
import Data.Typeable
import Data.Binary

data DaideError = TimerPopped
                | IMNotFirst
                | WrongEndian
                | WrongMagic
                | VersionIncomp
                | ManyIMs
                | IMFromServer
                | UnknownMsg
                | MsgTooShort
                | DMBeforeRM
                | RMNotFirst
                | ManyRMs
                | RMFromClient
                | InvalidToken Word8 Word8
                | WillDieSorry String
                deriving (Show, Typeable)

instance Error DaideError
instance Exception DaideError

         -- needed in DaideHandle
instance Error (Maybe DaideError)
instance Exception (Maybe DaideError)

class DaideErrorClass m where
  throwEM :: DaideError -> m a

errorCode :: DaideError -> Int
errorCode TimerPopped         = 0x01
errorCode IMNotFirst          = 0x02
errorCode WrongEndian         = 0x03
errorCode WrongMagic          = 0x04
errorCode VersionIncomp       = 0x05
errorCode ManyIMs             = 0x06
errorCode IMFromServer        = 0x07
errorCode UnknownMsg          = 0x08
errorCode MsgTooShort         = 0x09
errorCode DMBeforeRM          = 0x0A
errorCode RMNotFirst          = 0x0B
errorCode ManyRMs             = 0x0C
errorCode RMFromClient        = 0x0D
errorCode (InvalidToken _ _)  = 0x0E
errorCode (WillDieSorry _)    = 0x0F

errorFromCode :: Int -> DaideError
errorFromCode 0x01 =   TimerPopped
errorFromCode 0x02 =    IMNotFirst
errorFromCode 0x03 =   WrongEndian
errorFromCode 0x04 =    WrongMagic
errorFromCode 0x05 = VersionIncomp
errorFromCode 0x06 =       ManyIMs
errorFromCode 0x07 =  IMFromServer
errorFromCode 0x08 =    UnknownMsg
errorFromCode 0x09 =   MsgTooShort
errorFromCode 0x0A =    DMBeforeRM
errorFromCode 0x0B =    RMNotFirst
errorFromCode 0x0C =       ManyRMs
errorFromCode 0x0D =  RMFromClient
errorFromCode 0x0E =  InvalidToken 0 0
errorFromCode 0x0F =  WillDieSorry ""
errorFromCode _    = throw UnknownMsg
