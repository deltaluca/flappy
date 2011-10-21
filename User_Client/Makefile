all: lexer
	haxelib run nme update client.nmml linux -64 -debug
	haxelib run nme build client.nmml linux -64 -debug

lexer : daide/lexer.hlx
	hlex daide/lexer.hlx -haxe-gen daide/HLex.hx -package daide

run:
	haxelib run nme run client.nmml linux -64

clean:
	rm -rf Export
