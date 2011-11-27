{-# LANGUAGE DeriveDataTypeable #-}
module Diplomacy.Common.DipError where

import Diplomacy.Common.Data
import Diplomacy.Common.DipToken

import Control.Monad.Error
import Control.Exception
import Data.Typeable

data DipError = Paren [DipToken]
              | Syntax [DipToken]
              
              | CivilDisorder { disorderPower :: Power } -- specified power has been declared to be in Civil Disorder
               
              | ParseError String
              deriving (Eq, Show, Typeable)

instance Error DipError
instance Exception DipError

data DipParseError = WrongParen Int -- message recieved by server does not have correct parentheses
                   | SyntaxError Int -- message has a syntax error
                   deriving (Eq, Show, Typeable)
                            
