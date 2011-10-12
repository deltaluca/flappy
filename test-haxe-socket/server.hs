module Main where

import System.IO
import Network
import Monad

main = listen

listen :: IO ()
listen = do
  socket <- listenOn (PortNumber 4571)
  (handle, hostName, portNumber) <- accept socket
  hSetBuffering handle NoBuffering
  hSetBinaryMode handle True

  hPutData handle (HxString "hi from server!")

  msg <- hGetData handle
  putStrLn $ show msg

  msg <- hGetData handle
  putStrLn $ show msg

  msg <- hGetData handle
  putStrLn $ show msg

  hPutData handle (HxInt 10)
  
hGetMessage :: Handle -> IO String
hGetMessage handle = do
  c <- hGetChar handle
  if c == '\0'
    then return ""
    else do l <- hGetMessage handle
            return (c:l)

hPutData :: Handle -> HaxeType -> IO ()
hPutData handle dat = do
	hPutStr handle (hx_serialise dat)
	hPutChar handle '\0'
 
-----------------------

hGetData :: Handle -> IO HaxeType
hGetData handle = do
	string <- hGetMessage handle
	return (fst $ hx_deserialise string)

-----------------------

data HaxeType = HxString String | HxError String | HxInt Int

hx_deserialise :: String -> (HaxeType, String)
hx_deserialise (t:rest)
  | t == 'y' = hx_decode_str rest
  | t == 'z' = (HxInt 0, rest)
  | t == 'i' = hx_decode_int rest

hx_serialise :: HaxeType -> String
hx_serialise (HxString str) = ('y' : (show $ length url)) ++ (':' : url)
  where url = url_encode str
hx_serialise (HxInt 0) = "z"
hx_serialise (HxInt x) = 'i' : (show x)

instance Show HaxeType where
  show (HxString str) = "HxString \"" ++ str ++ "\""
  show (HxError str) = "HxError \"" ++ str ++ "\""
  show (HxInt ival) = "HxInt " ++ (show ival)

-----------------------

hx_decode_str :: String -> (HaxeType, String)
hx_decode_str str = (HxString outstr, reststr)
  where (size,(_:rest)) = istr str
        outstr = url_decode $ take size rest
        reststr = drop size rest

hx_decode_int :: String -> (HaxeType, String)
hx_decode_int str = (HxInt ival, rest)
  where (ival,rest) = istr str

url_decode :: String -> String
url_decode "" = ""
url_decode ('%':'2':'0':rest) = ' ' : url_decode rest
url_decode ('%':'2':'1':rest) = '!' : url_decode rest
url_decode ('%':'2':'2':rest) = '"' : url_decode rest
url_decode ('%':'2':'3':rest) = '#' : url_decode rest
url_decode ('%':'2':'4':rest) = '$' : url_decode rest
url_decode (x:rest) = x : url_decode rest

url_encode :: String -> String
url_encode "" = ""
url_encode (' ':rest) = "%20" ++ url_encode rest
url_encode ('!':rest) = "%21" ++ url_encode rest
url_encode ('"':rest) = "%22" ++ url_encode rest
url_encode ('#':rest) = "%23" ++ url_encode rest
url_encode ('$':rest) = "%24" ++ url_encode rest
url_encode (x:rest) = x : url_encode rest

istr :: String -> (Int,String)
istr = head . reads

split :: String -> Char -> [String]
split "" delim = [""]
split (c:cs) delim
  | c == delim = "" : rest
  | otherwise  = (c : head rest) : tail rest
  where rest = split cs delim
