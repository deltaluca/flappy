module Main where

import System.IO
import Network


main = listen

listen :: IO ()
listen = do
  socket <- listenOn (PortNumber 4571)
  (handle, hostName, portNumber) <- accept socket
  hSetBuffering handle NoBuffering

  hPutMessage handle "y15:hi from server!"
  string <- hGetMessage handle
  putStrLn string
  hPutMessage handle "y16:bye from server!"
  
hGetMessage :: Handle -> IO String
hGetMessage handle = do
  c <- hGetChar handle
  if c == '\0'
    then return ""
    else do l <- hGetMessage handle
            return (c:l)

hPutMessage :: Handle -> String -> IO ()
hPutMessage handle msg = do
	hPutStr handle msg
	hPutChar handle '\0'
  
