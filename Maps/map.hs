import Data.String.Utils
import Data.Graph
import System.IO
import Maybe

names = "province_names.txt"
links = "province_links.txt"
test_links = "t_links.txt"

data Province = 
    Inland  ProvinceName [LandBorder] [WaterBorder]
  | Coastal ProvinceName [LandBorder] [WaterBorder]
  | Water   ProvinceName [LandBorder] [WaterBorder]
  deriving (Show)

type MapLinks = ([Province],[Province],[Province])
type WaterBorder = Border
type LandBorder  = Border
type Border = String
type ProvinceName = String

getPName :: Province -> ProvinceName
getPName (Inland  n _ _) = n
getPName (Coastal n _ _) = n
getPName (Water   n _ _) = n

getPLands :: Province -> [LandBorder]
getPLands (Inland  _ l _) = l
getPLands (Coastal _ l _) = l
getPLands (Water   _ l _) = l

getPWaters :: Province -> [WaterBorder]
getPWaters (Inland  _ _ w) = w
getPWaters (Coastal _ _ w) = w
getPWaters (Water   _ _ w) = w

isCoastal (Coastal _ _ _) = True
isCoastal p = False

createArmyGraph (coast,inland,sea) = do
  let ids = assignID (coast,inland,sea)
  let armyMap = makeArmyMap (coast,inland,sea)
  let just_armyNodes = map (\(x,y) -> ((flip lookup) ids x,(flip lookup) ids y)) armyMap
  let armyNodes = map (\(x,y) -> (fromJust x,fromJust y)) just_armyNodes
  return $ buildG (1,length ids) armyNodes

makeArmyMap (coast,inland,_) =
  concat [[(name,l) | l <- lands] | (name,lands) <- provlinks]
  where
    provlinks = zip (map getPName (coast ++ inland)) (map getPLands (coast ++ inland))

-- Needs work to discriminate against non-coastal links
makeFleetMap (coast,_,sea) =
  concat [[(name,l) | l <- lands] | (name,lands) <- provlinks]
  where
    provlinks = zip (map getPName (coast ++ sea)) ((map getPLands (coast ++ sea)) ++ (map getPWaters (coast ++ sea)))

assignID :: MapLinks -> [(ProvinceName,Int)]
assignID (coast,inland,sea) =
 zip (map getPName (coast ++ inland ++ sea)) [1..]

-- Functions for conerting list-structure of provinces into a slightly
-- more readable custom data type form.

listToProvince ptype [[name],landborders,seaborders] =
  ptype name landborders seaborders

convertToProvince (coast,inland,sea) =
  (map (listToProvince Coastal) coast,
   map (listToProvince Inland)  inland,
   map (listToProvince Water)   sea)

-- Sorting out and parsing the provinces from a file

-- Splits a list of land provinces into those which are coastal, and those
-- which aren't.

inferCoastal lands = 
  ((filter ((/=0) . length . last)) lands,(filter ((==0) . length . last)) lands)

getLinks filename = do
  handle <- openFile filename ReadMode
  contents <- hGetContents handle
  let ret =  map (map (split ",")) $ map (split ";") $ lines contents
  return (tail (takeWhile (/=[["--Water--"]]) ret), tail (dropWhile (/=[["--Water--"]]) ret))

getNames filename = do
  handle <- openFile filename ReadMode
  contents <- hGetContents handle
  
  return $ map (\[x,y] -> (x,y)) $ map (split ",") $ lines contents

main = do
  provs <- getLinks test_links
  let (coast,inland) = inferCoastal $ fst provs
  let sea = snd provs
  return $ convertToProvince (coast,inland,sea)
  --putStrLn $ show $ convertToProvince (coast,inland,sea)
