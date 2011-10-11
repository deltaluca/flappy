def-uni:
	haxe -cp . -main Main -swf test.swf -swf-version 11 -swf-header 400:300:60:ffffff
	haxe -cp . -main Main -cpp /vol/bitbucket/ld509/cpp/flappy/test-haxe-socket -D HXCPP_M64 -D HXFCGI -lib nme --remap flash:nme
	cp /vol/bitbucket/ld509/cpp/flappy/test-haxe-socket/Main Main

	g++-4.6.1 main.cpp -o main 

def:
	haxe -cp . -main Main -swf test.swf -swf-version 11 -swf-header 400:300:60:ffffff
	haxe -cp . -main Main -cpp cpp -D HXCPP_M64 -D HXFCGI -lib nme --remap flash:nme
	cp cpp/Main Main

	g++ main.cpp -o main 
