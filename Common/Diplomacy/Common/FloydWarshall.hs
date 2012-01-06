module Diplomacy.Common.FloydWarshall(floydWarshall) where

import Diplomacy.Common.Data

import Data.Array
import qualified Data.Map as Map


  -- looks obscure but it's all just so that we have a nice interface to a fast array
floydWarshall :: MapDefinition -> (ProvinceNode, UnitType) -> ProvinceNode -> Maybe Int
floydWarshall mapDef (x, utyp) y = floydWarshall' utyp ! (x, y)
  where
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
                                           ProvCoastNode _ c -> Just c) $ mapDefProvNodes prov
          ic = elemIndex coast sortCoasts
      in
       case ic of
         Nothing -> error "inconsistent ProvCoastNode coast, the provNodes map doesn't contain it"
         Just i -> provinceId prov + (maxProvId - minProvId) * i
    floydWarshall' utyp = 