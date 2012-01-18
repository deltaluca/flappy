SERVER=localhost
PORT=16713

all: ser obs

keepdoing:
	zsh -c 'for i in {0..10} ; do make doall ; sleep 300 ; killall AiServer.exe ; killall learnbot ; killall randombot ; sleep 5 ; done'

doall:
	cd "${HOME}/.wine/drive_c/Program Files/daide/aiserver" && zsh -c 'for i in {0..9} ; do wine AiServer.exe -port=1234$$i -start & ; done'
	sleep 10
	cd AI/dist/build/randombot && zsh -c 'for i in {0..9} ; do for j in {0..5} ; do ./randombot $(SERVER) 1234$$i &> outp.$$i_$$j & ; done ; sleep 5 ; done'
	cd AI/dist/build/learnbot && zsh -c 'for i in {0..9} ; do ./learnbot $(SERVER) 1234$$i &> outp.$$i & ; sleep 5 ; done'
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

dumb6:
	cd AI/dist/build/dumbbot && zsh -c 'for i in {1..6} ; do ./dumbbot localhost 16713 +RTS -p &> outp.$$i & ; done'

learn7:
	cd AI/dist/build/learnbot && zsh -c 'for i in {1..7} ; do ./learnbot $(SERVER) $(PORT) &> outp.$$i & ; done'

learn:
	cd AI/dist/build/learnbot && zsh -c './learnbot $(SERVER) $(PORT) &'

debug:
	cd AI/Diplomacy/AI/Bots/DumbBot && ghci dumbbot.hs -fbreak-on-exception

cover:
	cd AI/dist/build/coverbot && zsh -c './coverbot $(SERVER) $(PORT)  &> outp &'

noredir:
	cd AI/dist/build/holdbot && zsh -c 'for i in {1..6} ; do ./holdbot $(SERVER) $(PORT) &> outp.$$i & ; done' && ./holdbot $(SERVER) $(PORT)

dumb7:
	cd AI/dist/build/dumbbot && zsh -c 'for i in {1..7} ; do ./dumbbot $(SERVER) $(PORT) +RTS -p &> outp.$$i & ; done'
