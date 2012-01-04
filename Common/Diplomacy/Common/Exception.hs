-- | Exceptions used by all Diplomacy components
module Diplomacy.Common.MoveErrors where

import Control.Monad.Error

data OrderListError = Incomplete |
                      
                      Redundant |
                      GameFinished

data MoveError = ArmyMoveIntoWater
               | FleetMoveToLand
               | 
                                      
instance Show MoveError where
  show ArmyMoveIntoWater = "An army cannot move into a water province"
  show FleetMoveToLand = "A fleet cannot move to an inland province"

instance Error MoveError where
  noMsg = MoveError "Unknown error"
  strMsg str = MoveErrorError str

                                      
                           