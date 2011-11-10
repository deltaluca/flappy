module Paths_DiplomacyCommon (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName
  ) where

import Data.Version (Version(..))
import System.Environment (getEnv)

version :: Version
version = Version {versionBranch = [0,1], versionTags = []}

bindir, libdir, datadir, libexecdir :: FilePath

bindir     = "/home/pater/.cabal/bin"
libdir     = "/home/pater/.cabal/lib/DiplomacyCommon-0.1/ghc-6.12.3"
datadir    = "/home/pater/.cabal/share/DiplomacyCommon-0.1"
libexecdir = "/home/pater/.cabal/libexec"

getBinDir, getLibDir, getDataDir, getLibexecDir :: IO FilePath
getBinDir = catch (getEnv "DiplomacyCommon_bindir") (\_ -> return bindir)
getLibDir = catch (getEnv "DiplomacyCommon_libdir") (\_ -> return libdir)
getDataDir = catch (getEnv "DiplomacyCommon_datadir") (\_ -> return datadir)
getLibexecDir = catch (getEnv "DiplomacyCommon_libexecdir") (\_ -> return libexecdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
