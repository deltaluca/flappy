-- The following bot is based on David Norman's DumbBot algorithm
-- Original DumbBot: http://www.ellought.demon.co.uk/dipai/dumbbot_source.zip
-- Short explanation: http://www.daide.org.uk/wiki/DumbBot_Algorithm

module Main where

import Diplomacy.AI.Bots.DumbBot.Scoring

import Diplomacy.AI.SkelBot.SkelBot
import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.DipBot
import Diplomacy.AI.SkelBot.Common

import Diplomacy.Common.DipMessage
import Diplomacy.Common.Data

import Data.Maybe
import Data.List
import System.Random
import Control.Monad.IO.Class
import Control.Monad.Random
import Control.Monad.Trans
import Control.Monad

import qualified Data.Map as Map

import Debug.Trace

-- pure brains

  -- we enforce deterministic scoring by NOT wrapping in RandT just yet
type DumbBrain o = Brain o ()

type DumbBrainMove = DumbBrain OrderMovement
type DumbBrainRetreat = DumbBrain OrderRetreat
type DumbBrainBuild = DumbBrain OrderBuild

-- impure brains
type DumbBrainCommT o = BrainCommT o ()

type DumbBrainMoveCommT = BrainCommT OrderMovement ()
type DumbBrainRetreatCommT = BrainCommT OrderRetreat ()
type DumbBrainBuildCommT = BrainCommT OrderBuild ()

main = skelBot dumbBot

dumbBot :: (MonadIO m) => DipBot m ()
dumbBot = DipBot { dipBotName = "FlappyDumbBot"
                 , dipBotVersion = 0.1
                 , dipBotBrainMovement = dumbBrainMoveComm
                 , dipBotBrainRetreat = dumbBrainRetreatComm
                 , dipBotBrainBuild = dumbBrainBuildComm
                 , dipBotProcessResults = dumbProcessResults
                 , dipBotInitHistory = dumbInitHistory }

withStdGen :: (MonadIO m) => RandT StdGen m a -> m a
withStdGen ran = do
  stdGen <- liftIO getStdGen
  ret <- runRandT ran stdGen
  liftIO $ setStdGen newStdGen  -- set new stdgen
  return ret

dumbBrainComm :: (MonadIO m, OrderClass o) => DumbBrain o () -> DumbBrainCommT o m ()
dumbBrainComm pureBrain = do
  stdGen <- liftIO getStdGen
  
  (_, newStdGen) <- liftBrain   -- lift pure brain
    . runBrain                  -- no underlying monad
    . runRandT pureBrain $ stdGen
  
  liftIO $ setStdGen newStdGen  -- set new stdgen

dumbBrainMoveComm :: (MonadIO m) => DumbBrainMoveCommT m ()
dumbBrainMoveComm = dumbBrainComm dumbBrainMove

dumbBrainRetreatComm :: (MonadIO m) => DumbBrainRetreatCommT m ()
dumbBrainRetreatComm = dumbBrainComm dumbBrainRetreat

dumbBrainBuildComm :: (MonadIO m) => DumbBrainBuildCommT m ()
dumbBrainBuildComm = dumbBrainComm dumbBrainBuild

dumbProcessResults :: [(Order, OrderResult)] -> () -> ()
dumbProcessResults _ = id

dumbInitHistory :: (MonadIO m) => m ()
dumbInitHistory = return ()
