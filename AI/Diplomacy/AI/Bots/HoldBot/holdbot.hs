module Main where

import Diplomacy.AI.SkelBot.SkelBot

data HoldDecision = Hold

type HoldBrain = BrainCommT HoldDecision () IO

main = skelBot holdBrain

holdBrain :: HoldBrain IO a
holdBrain = undefined