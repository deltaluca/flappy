{-# LANGUAGE DeriveDataTypeable #-}
module DiplomacyError where

import Control.Monad.Error
import Control.Exception
import DiplomacyData
import Data.Typeable
import Text.Parsec.Error

data DipError   -- message recieved by server does not have correct parentheses
              = WrongParen String

                -- message has a syntax error
              | SyntaxError String

                -- specified power has been declared to be in Civil Disorder
              | CivilDisorder { disorderPower :: Power }

              deriving (Show, Typeable)

instance Error DipError
instance Exception DipError
