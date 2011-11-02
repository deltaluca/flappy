all:
	haxelib run nme update client.nmml linux -64 -debug
	haxelib run nme build client.nmml linux -64 -debug

unparser: daide/Unparser.cx
	caxe daide/Unparser.cx -o daide --times
	
lexer : daide/lexer.hlx
	hlex daide/lexer.hlx -haxe-gen daide/HLex.hx -package daide
parser : daide/parser.hlr
	hllr daide/parser.hlr daide/HLlr.hx -haxe-gen -token Token -ast Message -index TU.index -package daide -lalr1

run:
	haxelib run nme run client.nmml linux -64

clean:
	rm -rf Export
