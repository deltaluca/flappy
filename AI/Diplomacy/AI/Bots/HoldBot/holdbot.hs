module Main where

import Diplomacy.AI.SkelBot.SkelBot

data HoldDecision = HoldDecision [Unit]

instance Decision HoldBrain HoldDecision where
  diplomise :: Decision -> [DipMessage]
  diplomise (HoldDecision units) = 


diplomise Hold = asd

type HoldBrain = BrainComm HoldDecision ()

main = skelBot holdBrain

holdBrain :: HoldBrain ()
holdBrain = forever $ do
  liftIO $ print "whatevs"
  unitPoss <- asksMapState unitPositions
  inMessage <- popInMessage
  
  result <- think pureBrain inMessage
  map someFunction unitPoss



