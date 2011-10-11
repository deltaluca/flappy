module Main where

import Network
import System.IO

main = ping

ping :: IO ()
ping = do
  handle <- connectTo "127.0.0.1" (PortNumber 4571)
  hSetBuffering handle NoBuffering
  hPutStr handle "Hello There"
  