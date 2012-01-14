-- |TSeq is like TChan with flushing(resetting)
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

-- |The TSeq datastructure
newtype TSeq a = TSeq (TVar (Seq a))

-- |creates a new TSeq in the STM monad
newTSeq :: STM (TSeq a)
newTSeq = return . TSeq =<< newTVar empty

-- |creates a new TSeq in the IO monad
newTSeqIO :: IO (TSeq a)
newTSeqIO = return . TSeq =<< newTVarIO empty

-- |lifts a Seq operation to a TSeq operation in the STM monad
liftSeq :: (Seq a -> b) -> (TSeq a -> STM b)
liftSeq f (TSeq tSequ) = do
  sequ <- readTVar tSequ
  return (f sequ)

-- |pushes a new element
writeTSeq :: TSeq a -> a -> STM ()
writeTSeq (TSeq tSequ) a = do
  writeTVar tSequ . (|> a) =<< readTVar tSequ

-- |pushes a new element to the front of the queue
requeueTSeq :: TSeq a -> a -> STM ()
requeueTSeq (TSeq tSequ) a = do
  writeTVar tSequ . (a <|) =<< readTVar tSequ

-- |pops an element from the queue
readTSeq :: TSeq a -> STM a
readTSeq (TSeq tVar) = do
  sequ <- readTVar tVar
  (a :< rest) <- if Seq.null sequ then retry else return (viewl sequ)
  writeTVar tVar rest
  return a

-- |reads an element from the queue without popping it
peekTSeq :: TSeq a -> STM a
peekTSeq (TSeq tVar) = do
  sequ <- readTVar tVar
  (a :< _) <- if Seq.null sequ then retry else return (viewl sequ)
  return a

-- |returns the underlying Seq in the STM monad
toSeq :: TSeq a -> STM (Seq a)
toSeq (TSeq tSequ) = readTVar tSequ

-- |creates a TSeq from
fromSeq :: Seq a -> STM (TSeq a)
fromSeq sequ = return . TSeq =<< newTVar sequ

-- |resets(flushes) the queue
resetTSeq :: TSeq a -> STM ()
resetTSeq (TSeq tSequ) = writeTVar tSequ empty

-- |modify the TSeq with the Seq function
modifyTSeq :: (Seq a -> Seq a) -> TSeq a -> STM ()
modifyTSeq f (TSeq tVar) = do
  sequ <- readTVar tVar
  writeTVar tVar (f sequ)