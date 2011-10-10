def:
	haxe -cp . -main Main -swf test.swf -swf-version 11 -swf-header 400:300:60:ffffff
	haxe -cp . -main Main -cpp /vol/bitbucket/ld509/cpp/flappy/test-haxe-socket -D HXCPP_M64 -D HXFCGI
	cp /vol/bitbucket/ld509/cpp/flappy/test-haxe-socket/Main Main

	g++-4.6.1 main.cpp -o main 
