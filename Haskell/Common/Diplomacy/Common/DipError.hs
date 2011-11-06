{-# LANGUAGE DeriveDataTypeable #-}
module Diplomacy.Common.DipError where

import Diplomacy.Common.Data
import Diplomacy.Common.DipToken

import Control.Monad.Error
import Control.Exception
import Data.Typeable

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
