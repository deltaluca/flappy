module Diplomacy.AI.Bots.LearnBot.PatternWeights  ( 
                                                  ) where

import Diplomacy.Common.Data
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Common

import Control.Monad
import Control.Applicative

import Data.Maybe
import Data.List
import Database.HDBC
import Database.HDBC.Sqlite3

import qualified Data.Map as Map

doNothing :: ( Functor m, Monad m, OrderClass o, MonadBrain o m, MonadGameKnowledge h m) => m ()
doNothing = do
  return ()



