module Diplomacy.AI.SkelBot.GameInfo where

import Diplomacy.Common.Data

  -- | Static game info
data GameInfo = GameInfo { gameInfoMapDef :: MapDefinition
                         , gameInfoPower :: Power }
              deriving (Show)