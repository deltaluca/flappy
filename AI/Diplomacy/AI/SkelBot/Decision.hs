module Diplomacy.AI.SkelBot.Decision where

import Diplomacy.Common.DipMessage

class Decision d where
  diplomise :: d -> [DipMessage]