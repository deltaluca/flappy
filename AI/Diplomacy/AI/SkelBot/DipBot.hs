module Diplomacy.AI.DipBot where

import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Decision

data DipBot d h = { botBrain :: BrainCommT d h IO () 
                  , defaultDecision :: IO d 
                  , initHistory :: IO h }
  