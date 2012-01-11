-- The following bot is based on David Norman's DumbBot algorithm
-- Original DumbBot: http://www.ellought.demon.co.uk/dipai/dumbbot_source.zip
-- Short explanation: http://www.daide.org.uk/wiki/DumbBot_Algorithm

-- the only functional difference between this bot and the original is
-- the sampling method used when generating moves

{-# LANGUAGE TypeSynonymInstances, FlexibleInstances, MultiParamTypeClasses #-}
module Main where

import Diplomacy.AI.Bots.DumbBot.DumbBot
import Diplomacy.AI.SkelBot.Scoring

import Diplomacy.AI.SkelBot.SkelBot
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.DipBot
import Diplomacy.AI.SkelBot.Common
import Diplomacy.AI.SkelBot.CommonCache

import Diplomacy.Common.Data

import Data.Maybe
import Data.List
import System.Random
import Control.Monad.IO.Class
import Control.Monad.Random
import Control.Monad.Trans
import Control.Monad
--import Control.DeepSeq

--import Debug.Trace

import qualified Data.Map as Map

_SEED = 0 :: Int

main = do
  --setStdGen (mkStdGen _SEED)
  skelBot dumbBot

dumbBot :: (Functor m, MonadIO m) => DipBot m ()
dumbBot = DipBot { dipBotName = "FlappyDumbBot"
                 , dipBotVersion = 0.1
                 , dipBotBrainMovement = dumbBrainMoveComm
                 , dipBotBrainRetreat = dumbBrainRetreatComm
                 , dipBotBrainBuild = dumbBrainBuildComm
                 , dipBotProcessResults = dumbProcessResults
                 , dipBotInitHistory = dumbInitHistory 
                 , dipBotGameOver = return ()
                 }

dumbProcessResults :: [(Order, OrderResult)] -> () -> ()
dumbProcessResults _ = id

dumbInitHistory :: (MonadIO m) => GameInfo -> GameState -> m ()
dumbInitHistory _ _ = return ()
