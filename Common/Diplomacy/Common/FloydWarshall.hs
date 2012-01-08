module Diplomacy.Common.FloydWarshall(floydWarshall) where

import Diplomacy.Common.Data

import Data.Array
import Data.List
import Data.Maybe(mapMaybe)
import Control.Monad (liftM, liftM2)
import qualified Data.Map as Map

--import Debug.Trace

  -- looks obscure but it's all just so that we have a nice interface to a fast access array
  -- Nothing represents no path
  -- it is symmetric
floydWarshall :: MapDefinition -> UnitType -> ProvinceNode -> ProvinceNode -> Maybe Int
floydWarshall mapDef utyp provFrom provTo = 
  floydWarshall' (map pid provNodes) ! (pid provFrom, pid provTo)
  where
    provNodes = case utyp of Army -> mapDefArmyNodes mapDef
                             Fleet -> mapDefFleetNodes mapDef
    provIds = map provinceId $ mapDefProvinces mapDef
    minProvId = minimum provIds
    maxProvId = maximum provIds
    maxNumCoasts = maximum . Map.elems . Map.map length $ mapDefProvNodes mapDef
    minPid = minProvId
    maxPid = minPid + maxNumCoasts * (maxProvId - minProvId)
    -- pids identify provinceNODEs, SPEED >> SPACE
    pid (ProvNode prov) = provinceId prov
    pid (ProvCoastNode prov coast) =
      let sortCoasts = sort . mapMaybe (\p -> case p of
                                           ProvNode _ -> Nothing
                                           ProvCoastNode _ c -> Just c) $
                       mapDefProvNodes mapDef Map.! prov
          ic = elemIndex coast sortCoasts
      in
       case ic of
         Nothing -> error "inconsistent ProvCoastNode coast, the provNodes map doesn't contain it"
         Just i -> provinceId prov + (maxProvId - minProvId) * i
    arrayRange = ((minPid, minPid), (maxPid, maxPid))
    initArray = listArray arrayRange (repeat Nothing)
                // [ ((pid x, pid y), Just 1)
                   | x <- provNodes, y <- adj x ]
    adj x = mapDefAdjacencies mapDef Map.! (x, utyp)
    
    -- the important part
    floydWarshall' :: [Int] -> Array (Int, Int) (Maybe Int)
    floydWarshall' [] = initArray
    floydWarshall' (i : is) = let prevArr = floydWarshall' is in
      prevArr // [ ((x, y), mini (prevArr ! (x, y)) (prevArr ! (x, i) + prevArr ! (i, y)))
                 | (x, y) <- range arrayRange]

--trc a = traceShow a a

mini Nothing a = a
mini a Nothing = a
mini a b = min a b

instance (Num a) => Num (Maybe a) where
  (+) = liftM2 (+)
  (*) = liftM2 (*)
  abs = liftM abs
  signum = liftM signum
  fromInteger = Just . fromInteger
  