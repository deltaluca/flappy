module Main where

import System.IO
import Network


main = listen

listen :: IO ()
listen = do
  socket <- listenOn (PortNumber 4571)
  (handle, hostName, portNumber) <- accept socket
  putStrLn hostName
  string <- hGetContents handle
  putStrLn string
  
  
  