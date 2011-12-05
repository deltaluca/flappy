-- | module for handling clients
module Diplomacy.Server.Client where

import Diplomacy.Common.DaideHandle
import Diplomacy.Common.DaideMessage
import Diplomacy.Common.DaideError
import Diplomacy.Common.TSeq

import Control.Monad.Error

data Client = Client { clientReceiver :: TSeq DaideMessage
                     , clientDispatcher :: TSeq DaideMessage }

_INITIAL_TIMEOUT = 30000000

handleClient :: DaideHandle ()
handleClient = do
  note "Connection established"
  initialMessage <- runDaideAsk $ askDaideTimed _INITIAL_TIMEOUT
  case initialMessage of
    IM _ -> return ()
    _ -> throwEM IMNotFirst
  runDaideTell $ tellDaide RM
  forever $ do
    liftIO . print $ "Waiting for message"
    message <- runDaideAsk askDaide
    liftIO . print $ "Message recieved: " ++ (show message)
    handleMessage message

handleMessage :: DaideMessage -> DaideHandle ()
handleMessage m = case m of
  IM _ -> throwEM ManyIMs
  RM -> throwEM RMFromClient
  DM dipMessage -> liftIO . print $ "Diplomacy Message: " ++ show dipMessage
  a -> throwEM (WillDieSorry (show a))
