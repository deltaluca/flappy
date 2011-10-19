{-# LANGUAGE DeriveDataTypeable #-}

module Main where

import Control.Monad
import System
import System.Console.GetOpt
import Network
import Maybe
import System.Console.CmdArgs


main = do
  x <- getCmdArgs
  print x
  

-- map
data DiplomacyMap = Map
                  deriving (Show)


parseMap :: String -> IO DiplomacyMap
parseMap mapName = return Map

-- command line options
data CLOpts = CLOptions
              { port :: Int
              , mapName :: String
              } deriving (Data, Typeable, Show)


getCmdArgs = do  
  progName <- getProgName
  cmdArgs $ CLOptions 
       { port = 1234            &= argPos 0 &= typ "PORT"
       , mapName = "defMap.map" &= argPos 1 &= typ "FILE"
       }
       &= program progName
       &= summary "Flappy AI server 0.1"
