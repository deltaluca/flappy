all: server client

clean:
	rm -f server client

client: client.hs
	ghc --make -o client client.hs

haxe-client-uni:
	haxelib run nme update client.nmml linux -64 -Duni
	haxelib run nme build client.nmml linux -64 -Duni

	haxelib run nme update client.nmml flash -Duni
	haxelib run nme build client.nmml flash -Duni

haxe-client:
	haxelib run nme update client.nmml linux -64
	haxelib run nme build client.nmml linux -64

	haxelib run nme update client.nmml flash
	haxelib run nme build client.nmml flash

haxe-run-flash:
#	haxelib run nme run client.nmml flash
	fp Export/flash/bin/MyApplication.swf 

haxe-run-flash-uni:
#	haxelib run nme run client.nmml flash -Duni
	fp /vol/bitbucket/ld509/cpp/Export/flash/bin/MyApplication.swf

haxe-run-cpp:
	haxelib run nme run client.nmml linux -64
haxe-run-cpp-uni:
	haxelib run nme run client.nmml linux -64 -Duni

server: server.hs
	ghc --make -o server server.hs
