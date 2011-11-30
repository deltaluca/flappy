

import Diplomacy.Common.Data (Order, Phase)


-- | Functions to resolve requested moves and change game state accordingly.
module Diplomacy.Common.GameRules where

{-| 
  This might or not be needed depending on whether valid
  moves are enforced syntactically
-}
isValidOrder :: Order -> Bool

{-|
  If the winning condition is satisfied, returns winning 
  player; Nothing if the game is not yet won.
-}
getGameWinner :: GameState -> Maybe Power
getGameWinner

{-|

  Pre: All orders are valid orders in Diplomacy

  Transforms a game state after the orders
  are submitted. According to the phase the behaviour
  is different.

-}
applyOrder :: [Order] -> Phase -> GameState -> GameState




