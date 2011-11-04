{-# LANGUAGE DeriveDataTypeable #-}
module DiplomacyError where

import Control.Monad.Error
import Control.Exception
import DiplomacyData
import Data.Typeable
import DiplomacyToken

data DipError   -- message recieved by server does not have correct parentheses
              = WrongParen [DipToken]

                -- message has a syntax error
              | SyntaxError [DipToken]

                -- specified power has been declared to be in Civil Disorder
              | CivilDisorder { disorderPower :: Power }
              | ParseError String

              deriving (Show, Typeable)

instance Error DipError
instance Exception DipError
