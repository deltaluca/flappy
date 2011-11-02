{-# LANGUAGE DeriveDataTypeable #-}
module DaideError where

import Control.Monad.Error
import Control.Exception
import Data.Typeable
import Text.Parsec.Error

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
                | InvalidToken
                | ParseError ParseError
                deriving (Show, Typeable)

instance Error DaideError
instance Exception DaideError

errorCode :: DaideError -> Int
errorCode TimerPopped   = 0x01
errorCode IMNotFirst    = 0x02
errorCode WrongEndian   = 0x03
errorCode WrongMagic    = 0x04
errorCode VersionIncomp = 0x05
errorCode ManyIMs       = 0x06
errorCode IMFromServer  = 0x07
errorCode UnknownMsg    = 0x08
errorCode MsgTooShort   = 0x09
errorCode DMBeforeRM    = 0x0A
errorCode RMNotFirst    = 0x0B
errorCode ManyRMs       = 0x0C
errorCode RMFromClient  = 0x0D
errorCode InvalidToken  = 0x0E
