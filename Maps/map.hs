import Text.ParserCombinators.Parsec
import System.IO

data DMap = MDF [Power] ([Supply],NSupply) [ProvinceAdj]
  deriving (Show)

data ProvinceAdj = PAdj Province [UnitAdj]
  deriving (Show)
data UnitAdj = UAdj UType [AdjProv]
  deriving (Show)
data UType = Unit UT | CUnit UT Coast
  deriving (Show)
data AdjProv = AProv Province | ACst Province Coast
  deriving (Show)
data Supply  = Supp Power [Province]
  deriving (Show)

type Power = String
type NSupply = [Province]
type Province = String
type Coast = String
type UT = String

mapFile =
  do  result <- line
      eof
      return result

-- Need to make it more flexible, ie. accepts extra spaces and stuff
line = 
  do  mdf_start <- string "MDF"
      many (oneOf " \n")
      powers <- getPowers
      many (oneOf " \n")
      supply <- getSupplyProvs
      many (oneOf " \n")
      adjacency <- getAdjacencies
      eol
      return (MDF powers supply adjacency)

getAdjacencies =
  do  char '('
      contents <- many getProvAdjacency
      char ')'
      return contents

getProvAdjacency =
  do  char '('
      pname <- many (noneOf "(")
      units <- many getUnits
      char ')'
      return (PAdj pname units)

unitCoast = 
  do  char '('
      pname <- many (noneOf " ")
      char ' '
      pcoast <- many (noneOf ")")
      char ')'
      return (CUnit pname pcoast)
     
unitStd =
  do  uname <- many (noneOf " ")
      return (Unit uname)

-- Two cases of coast to add here
getUnits =
  do  char '('
      unit <- ((try unitCoast) <|> unitStd)
      char ' '
      links <- many getAdj --sepBy (many (noneOf " )")) (char ' ')
      char ')'
      return (UAdj unit links)

getAdj = 
  do  adjacency <- ((try adjCoast) <|> adjStd)
      many (char ' ')
      return adjacency

adjCoast =
  do  char '('
      pname <- many1 (noneOf " ")
      char ' '
      pcoast <- many1 (noneOf ")")
      char ')'
      return (ACst pname pcoast)

adjStd =
  do  pname <- many1 (noneOf " )")
      return (AProv pname) 
  
getPowers =
  do  char '('  
      contents <- sepBy (many (noneOf ") ")) (char ' ')
      char ')'
      return contents

getSupplyProvs :: GenParser Char st ([Supply],NSupply)
getSupplyProvs = 
  do  char '('
      -- Get supplies
      char '('
      supplies <- many getSupply
      char ')'
      -- Get non-supplies
      char '('
      nsupplies <- sepBy (many (noneOf ") ")) (char ' ')
      char ')'
      char ')'
      return (supplies,nsupplies)

getSupply =
  do  char '('
      powname <- many (noneOf " ")
      many (char ' ')
      provinces <- sepBy (many (noneOf ") ")) (char ' ')
      char ')'
      return (Supp powname provinces)

eol :: GenParser Char st Char
eol = char '\n'

parseMap input = parse mapFile "(unknown)" input
  
----------------------------------------------------------
-- Map based functions
--

main = do
  handle <- openFile "std_map_def.txt" ReadMode
  contents <- hGetContents handle
  return contents

