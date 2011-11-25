all:
	haxelib run nme update client.nmml linux -64
	haxelib run nme build client.nmml linux -64

unparser: daide/Unparser.cx
	caxe $(SCX) daide -o daide --times
mipmap: gui/MipMap.cx
	caxe gui -o gui --times
	
lexer : daide/lexer.hlx
	hlex daide/lexer.hlx -haxe daide/HLex.hx -package daide -token Token
parser : daide/parser.hlr
	hllr daide/parser.hlr daide/HLlr.hx -haxe -token Token -index TU.index -package daide -lalr1

run:
	haxelib run nme run client.nmml linux -64

clean:
	rm -rf Export
