GHC=ghc $(GHC_OPTS)
GHC_OPTS=--make -fwarn-missing-methods -Wall -fno-warn-missing-signatures -fno-warn-unused-do-bind # -Werror

all: server

server: server.hs DaideError.hs DaideClient.hs DaideMessage.hs DaideError.hs DiplomacyMessage.hs DiplomacyToken.hs
	$(GHC) -o server server.hs

clean:
	rm -f *.o *.hi server

fuck:
	$(GHC) -o server server.hs -ddump-cmm