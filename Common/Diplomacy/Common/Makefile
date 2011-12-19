GHC=ghc $(GHC_OPTS)
GHC_OPTS=--make -fwarn-missing-methods -Wall -fno-warn-missing-signatures -fno-warn-unused-do-bind #-Werror

all: cabal

server: DaideError.hs DaideHandle.hs DaideMessage.hs DaideError.hs DipMessage.hs DipToken.hs
	$(GHC) *.hs

clean:
	rm -f *.o *.hi server

cabal:
	cd ../../ && cabal install