module DaideError where

import Control.Monad.Error

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

instance Error DaideError