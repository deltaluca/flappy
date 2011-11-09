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
              deriving (Show, Typeable)

instance Error DipError
instance Exception DipError

data DipParseError = WrongParen Int -- message recieved by server does not have correct parentheses
                   | SyntaxError Int -- message has a syntax error
                   deriving Typeable
                            
                            
-- type LolList a = ([a] -> [a])


-- append = (.)

-- cons a = ((a :) .)

-- listify = ($ id)

-- lolmap f = (map f .)

-- data T = T [a] (

-- length :: [a] -> ((a -> b -> b) -> b -> b)
-- length a b c = foldr b c a

-- compare :: T -> T -> Int
-- compare 


-- compare (length xs) (length ys) => O(1) amortized

-- min (min (length xs) (len y2)) (min (len zs) (len ts))

-- min (min 2 2) (min 1000000 100000000)