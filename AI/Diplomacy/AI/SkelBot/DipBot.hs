module Diplomacy.AI.SkelBot.DipBot where

import Diplomacy.AI.SkelBot.Brain
import Diplomacy.AI.SkelBot.Decision

data DipBot d h = DipBot { botBrain :: BrainCommT d h IO () d
                         , defaultDecision :: IO d 
                         , initHistory :: IO h }


