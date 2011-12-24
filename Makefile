all: ser obs

ser:
	cd "/home/exfalso/.wine/drive_c/Program Files/daide/aiserver" && wine AiServer.exe -start &

obs:
	cd UserClient && make run &

random7:
	cd AI/dist/build/randombot && zsh -c 'for i in {1..7} ; do ./randombot localhost 16713 &> outp.$$i & ; done'

holdrandom:
	cd AI/dist/build/randombot && ./randombot localhost 16713 &
	cd AI/dist/build/holdbot && zsh -c 'for i in {1..6} ; do ./holdbot localhost 16713 &> outp.$$i & ; done' 


viewerr:
	cd AI/dist/build/randombot && emacs outp.*