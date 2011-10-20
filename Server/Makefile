GHC=ghc --make

all: server

server: server.hs serial
	$(GHC) -o server server.hs

serial: Serial.hs
