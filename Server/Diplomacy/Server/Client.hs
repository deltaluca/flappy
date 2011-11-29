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
  initialMessage <- askHandleTimed _INITIAL_TIMEOUT
  case initialMessage of
    IM _ -> return ()
    _ -> throwError IMNotFirst
  tellHandle RM
  forever $ do
    liftIO . print $ "Waiting for message"
    message <- askHandle
    liftIO . print $ "Message recieved: " ++ (show message)
    handleMessage message

handleMessage :: DaideMessage -> DaideHandle ()
handleMessage m = case m of
  IM _ -> throwError ManyIMs
  RM -> throwError RMFromClient
  DM dipMessage -> liftIO . print $ "Diplomacy Message: " ++ show dipMessage
  _ -> throwError InvalidToken
