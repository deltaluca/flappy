{-# LANGUAGE 
  MultiParamTypeClasses
, FlexibleInstances
, GeneralizedNewtypeDeriving
, FunctionalDependencies #-}

module Diplomacy.AI.SkelBot.Brain ( Brain, BrainT
                                  , BrainComm, BrainCommT
                                  , mapBrainT
                                  , runBrainT
                                  , runBrain
                                  , runBrainCommT
                                  , runGameKnowledgeT
                                  , decide
                                  , GameKnowledgeT
                                  , MonadGameKnowledge(..)
                                  , MonadBrain(..)) where

import Diplomacy.Common.Data
import Diplomacy.AI.SkelBot.Decision
import Diplomacy.AI.SkelBot.Comm
import Diplomacy.AI.SkelBot.GameState
import Diplomacy.AI.SkelBot.GameInfo

import Control.Monad.Reader
import Control.Monad.State
import Control.Monad.Identity
import Control.Concurrent.STM
import Data.Functor

newtype GameKnowledgeT h m a = GameKnowledge (StateT h (ReaderT GameInfo m) a)
                             deriving (Monad, MonadReader GameInfo, MonadState h)

instance MonadTrans (GameKnowledgeT h) where
  lift = GameKnowledge . lift . lift

runGameKnowledgeT :: (Monad m) => GameKnowledgeT h m a -> GameInfo -> h -> m (a, h)
runGameKnowledgeT (GameKnowledge knowledge) mapDef initHistory =
  runReaderT (runStateT knowledge initHistory) mapDef

class (Monad m) => MonadGameKnowledge h m | m -> h where
  askGameInfo :: m GameInfo
  asksGameInfo :: (GameInfo -> a) -> m a
  getHistory :: m h
  getsHistory :: (h -> a) -> m a
  modifyHistory :: (h -> h) -> m ()
  putHistory :: h -> m ()

instance (Monad m) => MonadGameKnowledge h (GameKnowledgeT h m) where
  askGameInfo = GameKnowledge ask
  getHistory = GameKnowledge get
  asksGameInfo = GameKnowledge . asks
  getsHistory = GameKnowledge . gets
  modifyHistory = GameKnowledge . modify
  putHistory = GameKnowledge . put

  -- |h = history type, d = decision type
newtype BrainT d h m a = Brain (ReaderT GameState (StateT (Maybe d) (GameKnowledgeT h m)) a)
                       deriving (Monad, MonadReader GameState, MonadState (Maybe d))

type DecisionVar d = TVar (Maybe d)

newtype BrainCommT d h m a = BrainComm (ReaderT (DecisionVar d) (CommT (BrainT d h m)) a)
                           deriving (Monad)

instance Decision d => MonadTrans (BrainT d h) where
  lift = Brain . lift . lift . lift

instance Decision d => MonadTrans (BrainCommT d h) where
  lift = BrainComm . lift . lift . lift

instance (MonadIO m) => MonadIO (GameKnowledgeT h m) where
  liftIO = GameKnowledge . lift . liftIO

instance (MonadIO m, Decision d) => MonadIO (BrainT d h m) where
  liftIO = Brain . lift . liftIO

instance (MonadIO m, Decision d) => MonadIO (BrainCommT d h m) where
  liftIO = BrainComm . lift . lift . lift . liftIO

instance (Monad m, Decision d) => MonadGameKnowledge h (BrainT d h m) where
  askGameInfo = liftGameKnowledge askGameInfo
  getHistory = liftGameKnowledge getHistory
  asksGameInfo = liftGameKnowledge . asksGameInfo
  getsHistory = liftGameKnowledge . getsHistory
  modifyHistory = liftGameKnowledge . modifyHistory
  putHistory = liftGameKnowledge . putHistory
  
class (Monad m, Decision d) => MonadBrain d m | m -> d where
  askGameState :: m GameState
  asksGameState :: (GameState -> a) -> m a
  getDecision :: m (Maybe d)
  getsDecision :: (d -> a) -> m (Maybe a)
  putDecision :: Maybe d -> m ()

instance (Monad m, Decision d) => MonadBrain d (BrainT d h m) where
  askGameState = Brain ask
  asksGameState = Brain . asks
  getDecision = Brain get
  getsDecision f = maybe (return Nothing) (return . Just . f) =<< getDecision
  putDecision = Brain . put

liftGameKnowledge :: (Monad m, Decision d) => GameKnowledgeT h m a -> BrainT d h m a
liftGameKnowledge = Brain . lift . lift

runBrainT :: (Decision d) => BrainT d h m a -> GameState -> GameKnowledgeT h m (a, Maybe d)
runBrainT (Brain brain) mapState = runStateT (runReaderT brain mapState) Nothing

mapBrainT :: (Monad m, Monad n, Decision d) =>
             (m ((a, Maybe d), h) -> n ((b, Maybe d), h)) -> BrainT d h m a -> BrainT d h n b
mapBrainT f mbrain = do
  a <- askGameState
  b <- askGameInfo
  c <- getHistory
  ((ret, d), c2) <- lift . f $ runGameKnowledgeT (runBrainT mbrain a) b c
  putHistory c2
  putDecision d
  return ret

type Brain d h = BrainT d h Identity
type BrainComm d h = BrainCommT d h IO

mapBrain :: (Monad m, Decision d) => (((a, Maybe d), h) -> m ((b, Maybe d), h)) -> Brain d h a -> BrainT d h m b
mapBrain f = mapBrainT (f . runIdentity)

runBrain :: (Monad m, Decision d) => Brain d h a -> BrainT d h m a
runBrain = mapBrain return

liftBrain :: (Monad m, Decision d) => BrainT d h m a -> BrainCommT d h m a
liftBrain = BrainComm . lift . lift

instance (MonadIO m, Decision d) => MonadComm (BrainCommT d h m) where
  popInMessage = BrainComm . lift $ popInMessage
  pushOutMessage = BrainComm . lift . pushOutMessage

instance (Monad m, Decision d) => MonadBrain d (BrainCommT d h m) where
  askGameState = liftBrain askGameState
  asksGameState = liftBrain . asksGameState
  getDecision = liftBrain getDecision
  getsDecision = liftBrain . getsDecision
  putDecision = liftBrain . putDecision

instance (Monad m, Decision d) => MonadGameKnowledge h (BrainCommT d h m) where
  askGameInfo = liftBrain askGameInfo
  getHistory = liftBrain getHistory
  asksGameInfo = liftBrain . asksGameInfo
  getsHistory = liftBrain . getsHistory
  modifyHistory = liftBrain . modifyHistory
  putHistory = liftBrain . putHistory

runBrainCommT :: (Monad m, Decision d) => BrainCommT d h m a -> DecisionVar d -> InMessageQueue -> OutMessageQueue -> BrainT d h m a
runBrainCommT (BrainComm m) dVar inq outq = runCommT (runReaderT m dVar) inq outq

decide :: (MonadIO m, Decision d) => d -> BrainCommT d h m ()
decide decision = do
  tVar <- BrainComm ask
  liftIO . atomically $ do 
    writeTVar tVar (Just decision)
