module Diplomacy.Common.TSeq(liftSeq, TSeq, 
                             writeTSeq,
                             requeueTSeq,
                             readTSeq,
                             newTSeq,
                             newTSeqIO,
                             peekTSeq,
                             toSeq,
                             fromSeq,
                             resetTSeq,
                             modifyTSeq) where

import Control.Concurrent.STM
import Data.Sequence as Seq

  -- | TSeq = TChan with finer control
newtype TSeq a = TSeq (TVar (Seq a))

newTSeq :: STM (TSeq a)
newTSeq = return . TSeq =<< newTVar empty

newTSeqIO :: IO (TSeq a)
newTSeqIO = return . TSeq =<< newTVarIO empty

liftSeq :: (Seq a -> b) -> (TSeq a -> STM b)
liftSeq f (TSeq tSequ) = do
  sequ <- readTVar tSequ
  return (f sequ)

writeTSeq :: TSeq a -> a -> STM ()
writeTSeq (TSeq tSequ) a = do
  writeTVar tSequ . (|> a) =<< readTVar tSequ

requeueTSeq :: TSeq a -> a -> STM ()
requeueTSeq (TSeq tSequ) a = do
  writeTVar tSequ . (a <|) =<< readTVar tSequ

readTSeq :: TSeq a -> STM a
readTSeq (TSeq tVar) = do
  sequ <- readTVar tVar
  (a :< rest) <- if Seq.null sequ then retry else return (viewl sequ)
  writeTVar tVar rest
  return a

peekTSeq :: TSeq a -> STM a
peekTSeq (TSeq tVar) = do
  sequ <- readTVar tVar
  (a :< _) <- if Seq.null sequ then retry else return (viewl sequ)
  return a

toSeq :: TSeq a -> STM (Seq a)
toSeq (TSeq tSequ) = readTVar tSequ

fromSeq :: Seq a -> STM (TSeq a)
fromSeq sequ = return . TSeq =<< newTVar sequ

resetTSeq :: TSeq a -> STM ()
resetTSeq (TSeq tSequ) = writeTVar tSequ empty

modifyTSeq :: (Seq a -> Seq a) -> TSeq a -> STM ()
modifyTSeq f (TSeq tVar) = do
  sequ <- readTVar tVar
  writeTVar tVar (f sequ)