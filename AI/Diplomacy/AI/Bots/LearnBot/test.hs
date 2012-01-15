
import Test.QuickCheck

replicateM Int List

cantor :: Int -> Int -> Int
cantor a b = hopUll (a+1) (b+1) - 1
  where 
   hopUll a b = ((a + b - 2)*(a + b - 1)) `div` 2 + a 

ncant :: [Int] -> Int
ncant [x] = x
ncant l = ncant' l
  where
    ncant' []     = error "ncant' []"
    ncant' [a,b]  = cantor a b
    ncant' (x:xs) = cantor x $ ncant' xs

decantor :: Int ->  [Int]
decantor h = [a - 1, b-1]
  where 
    [a,b] = deHopUll (h + 1)
    deHopUll h = [i, c - i + 2]
      where
        i = h - delt c
        c :: Int
        c = fromIntegral $ floor $ sqrt (fromIntegral (2*h)) - 0.5
        delt x = (x * (1 + x)) `div` 2
    
de_ncant :: Int -> Int -> [Int]
de_ncant 1 x = [x]
de_ncant 2 x = decantor x
de_ncant n x = de_ncant' n x
  where
    de_ncant' 0 _ = error "de_ncant called with 0 dimension"
    de_ncant' n' x' = a : de_ncant (n'-1) a' 
      where
        [a,a'] = decantor x' 
