-- |Floyd Warshall algorithm for Diplomacy mapdefinitions
module Diplomacy.Common.FloydWarshall(floydWarshall) where

import Diplomacy.Common.Data

import Control.Monad.ST
import Data.Array
import Data.Array.ST
import Data.List
import Data.Maybe(mapMaybe)
import Control.Monad (liftM, liftM2)
import qualified Data.Map as Map

-- |wrapper around floydWarshallArr to hide the underlying array
floydWarshall :: MapDefinition -> UnitType -> ProvinceNode -> ProvinceNode -> Maybe Int
floydWarshall mapDef utyp = let
  (cacheThisPleaseArmy, pid) = floydWarshallArr mapDef Army
  (cacheThisPleaseFleet, _) = floydWarshallArr mapDef Fleet
  in
   \provFrom provTo -> case utyp of
     Army -> cacheThisPleaseArmy ! (pid provFrom, pid provTo)
     Fleet -> cacheThisPleaseFleet ! (pid provFrom, pid provTo)

-- |returns a distance array (Nothing = no path) together with a mapping function
floydWarshallArr :: MapDefinition -> UnitType -> (Array (Int, Int) (Maybe Int), ProvinceNode -> Int)
floydWarshallArr mapDef utyp = (runSTArray (floydWarshall'' (map pid provNodes)), pid)
  where
    provNodes = case utyp of Army -> mapDefArmyNodes mapDef
                             Fleet -> mapDefFleetNodes mapDef
    provIds = map provinceId $ mapDefProvinces mapDef
    minProvId = minimum provIds
    maxProvId = maximum provIds
    maxNumCoasts = maximum . Map.elems . Map.map length $ mapDefProvNodes mapDef
    minPid = minProvId
    maxPid = minPid + maxNumCoasts * (maxProvId - minProvId)
    -- |the ProvinceNode -> Int mapping function. pid = provid + num * coastid where num is the number of provinces
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
    adj x = mapDefAdjacencies mapDef Map.! (x, utyp)

    -- |the important part, uses a mutable ST array
    floydWarshall'' :: [Int] -> ST s (STArray s (Int, Int) (Maybe Int))
    floydWarshall'' [] = do
      narr <- newListArray arrayRange (repeat Nothing)
      mapM (\xy -> writeArray narr xy (Just 1)) $
        [ (pid x, pid y) | x <- provNodes, y <- adj x ]
      return narr
    floydWarshall'' (i : is) = do
      arr <- floydWarshall'' is
      flip mapM_ (range arrayRange) $ \(x, y) -> do
        xi <- readArray arr (x, i)
        iy <- readArray arr (i, y)
        xy <- readArray arr (x, y)
        writeArray arr (x, y) $ mini xy (xi + iy)
      return arr

-- |the default Ord implementation interprets Notthing as smaller than everything
mini Nothing a = a
mini a Nothing = a
mini a b = min a b

instance (Num a) => Num (Maybe a) where
  (+) = liftM2 (+)
  (*) = liftM2 (*)
  abs = liftM abs
  signum = liftM signum
  fromInteger = Just . fromInteger
