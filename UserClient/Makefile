all:
	haxelib run nme update client.nmml linux -64 -debug
	haxelib run nme build client.nmml linux -64 -debug

unparser: daide/Unparser.cx
	caxe $(SCX) daide -o daide --times
	
lexer : daide/lexer.hlx
	hlex daide/lexer.hlx -haxe daide/HLex.hx -package daide -token Token
parser : daide/parser.hlr
	hllr daide/parser.hlr daide/HLlr.hx -haxe -token Token -index TU.index -package daide -lalr1

maplexer : map/lexer.hlx
	hlex map/lexer.hlx -haxe map/HLex.hx -package map -token PathToken
mapparser : map/parser.hlr
	hllr map/parser.hlr map/HLlr.hx -haxe -token PathToken -index PTU.index -package map -lalr1

run:
	haxelib run nme run client.nmml linux -64

clean:
	rm -rf Export
