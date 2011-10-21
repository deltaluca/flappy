GHC=ghc --make

all: server

server: server.hs DaideError.hs DaideClient.hs DaideMessage.hs DaideError.hs DiplomacyMessage.hs
	$(GHC) -o server server.hs

clean:
	rm *.o