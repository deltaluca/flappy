all: ser obs

ser:
	cd "${HOME}/.wine/drive_c/Program Files/daide/aiserver" && wine AiServer.exe -start &

obs:
	cd UserClient && make run &

random6:
	cd AI/dist/build/randombot && zsh -c 'for i in {1..6} ; do ./randombot localhost 16713 &> outp.$$i & ; done'

random7:
	cd AI/dist/build/randombot && zsh -c 'for i in {1..7} ; do ./randombot localhost 16713 &> outp.$$i & ; done'

holdrandom:
	cd AI/dist/build/randombot && ./randombot localhost 16713 &
	cd AI/dist/build/holdbot && zsh -c 'for i in {1..6} ; do ./holdbot localhost 16713 &> outp.$$i & ; done' 

hold6:
	cd AI/dist/build/holdbot && zsh -c 'for i in {1..6} ; do ./holdbot localhost 16713 &> outp.$$i & ; done'

viewerr:
	cd AI/dist/build/randombot && emacs outp.*

dumb:
	cd AI/dist/build/dumbbot && zsh -c './dumbbot localhost 16713 +RTS -p &'

learn7:
	cd AI/dist/build/learnbot && zsh -c 'for i in {1..7} ; do ./learnbot localhost 16713 &> outp.$$i & ; done'

learn:
	cd AI/dist/build/learnbot && zsh -c './learnbot localhost 16713 +RTS -p &'


debug:
	cd AI/Diplomacy/AI/Bots/DumbBot && ghci dumbbot.hs -fbreak-on-exception

cover:
	cd AI/dist/build/coverbot && zsh -c './coverbot localhost 16713  &> outp &'

noredir:
	cd AI/dist/build/holdbot && zsh -c 'for i in {1..6} ; do ./holdbot localhost 16713 &> outp.$$i & ; done' && ./holdbot localhost 16713
