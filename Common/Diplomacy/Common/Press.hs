-- |module to hold all Press datatypes
module Diplomacy.Common.Press ( PressMessage (..)
                              , PressProposal (..)
                              , PressReply (..)
                              , InMessage(..)
                              , OutMessage(..)
                              ) where

import Diplomacy.Common.Data
import Diplomacy.Common.DipToken

-- |incoming messages
data InMessage = InMessage { inMessageFrom :: Power
                           , inMessageTo :: [Power]
                           , inMessageMessage :: PressMessage }
               deriving (Eq, Show)

-- |outgoing messages
data OutMessage = OutMessage { outMessageTo :: [Power]
                             , outMessageMessage :: PressMessage }
                deriving (Eq, Show)

data PressMessage = PressProposal PressProposal
                  | PressReply PressReply
                  | PressInfo PressProposal
                  | PressCapable [DipToken]
                  deriving (Eq, Show)

data PressReply = PressAccept PressMessage
                | PressReject PressMessage
                | PressRefuse PressMessage
                | PressHuh PressMessage
                | PressCancel PressMessage
                deriving (Eq, Show)

data PressProposal = ArrangeDraw
                   | ArrangeSolo Power
                   | ArrangeAlliance [Power] [Power]
                   | ArrangePeace [Power]
                   | ArrangeNot PressProposal
                   | ArrangeUndo PressProposal
                   deriving (Eq, Show)
