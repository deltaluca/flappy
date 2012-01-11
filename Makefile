SERVER=localhost
PORT=16713

all: ser obs

ser:
	cd "${HOME}/.wine/drive_c/Program Files/daide/aiserver" && wine AiServer.exe -start &

obs:
	cd UserClient && make run &

random6:
	cd AI/dist/build/randombot && zsh -c 'for i in {1..6} ; do ./randombot localhost 16713 &> outp.$$i & ; done'

random7:
	cd AI/dist/build/randombot && zsh -c 'for i in {1..7} ; do ./randombot $(SERVER) $(PORT) &> outp.$$i & ; done'

holdrandom:
	cd AI/dist/build/randombot && ./randombot $(SERVER) $(PORT) &
	cd AI/dist/build/holdbot && zsh -c 'for i in {1..6} ; do ./holdbot $(SERVER) $(PORT) &> outp.$$i & ; done' 

hold6:
	cd AI/dist/build/holdbot && zsh -c 'for i in {1..6} ; do ./holdbot $(SERVER) $(PORT) &> outp.$$i & ; done'

viewerr:
	cd AI/dist/build/randombot && emacs outp.*

dumb:
	cd AI/dist/build/dumbbot && zsh -c './dumbbot $(SERVER) $(PORT) +RTS -p &'

learn7:
	cd AI/dist/build/learnbot && zsh -c 'for i in {1..7} ; do ./learnbot $(SERVER) $(PORT) &> outp.$$i & ; done'

learn:
	cd AI/dist/build/learnbot && zsh -c './learnbot $(SERVER) $(PORT) +RTS -p &> outp &'

debug:
	cd AI/Diplomacy/AI/Bots/DumbBot && ghci dumbbot.hs -fbreak-on-exception

cover:
	cd AI/dist/build/coverbot && zsh -c './coverbot $(SERVER) $(PORT)  &> outp &'

noredir:
	cd AI/dist/build/holdbot && zsh -c 'for i in {1..6} ; do ./holdbot $(SERVER) $(PORT) &> outp.$$i & ; done' && ./holdbot $(SERVER) $(PORT)

dumb7:
	cd AI/dist/build/dumbbot && zsh -c 'for i in {1..7} ; do ./dumbbot $(SERVER) $(PORT) +RTS -p &> outp.$$i & ; done'
