import Text.ParserCombinators.Parsec

data DMap = MDF [Power] ([Supply],NSupply) [ProvinceAdj]
  deriving (Show)

-- add coastal?
data ProvinceAdj = PAdj Province [UnitAdj]
  deriving (Show)
data UnitAdj = UAdj UType [AdjProv]
  deriving (Show)
data AdjProv = AProv Province | ACst Province Coast
  deriving (Show)
data Supply  = Supp Power [Province]
  deriving (Show)

type Power = String
type NSupply = [Province]
type Province = String
type Coast = String
type UType = String

mapFile =
  do  result <- line
      eof
      return result

-- Need to make it more flexible, ie. accepts extra spaces and stuff
line = 
  do  mdf_start <- many (noneOf "(")
      powers <- getPowers
      supply <- getSupplyProvs
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

getUnits =
  do  char '('
      unit <- many (noneOf " ")
      char ' '
      links <- sepBy (many (noneOf " )")) (char ' ')
      char ')'
      return (UAdj unit (map AProv links))

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
      provinces <- sepBy (many (noneOf ") ")) (char ' ')
      char ')'
      return (Supp powname provinces)

eol :: GenParser Char st Char
eol = char '\n'

parseMap input = parse mapFile "(unknown)" input
  

