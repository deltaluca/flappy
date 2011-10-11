package;

import Socket;

class Main {
	static var sock = new Socket();
	static function main() {
		sock.connect("localhost",4569, function() {
			sock.receive(function (dat) {
				trace(dat);
				sock.send("Hello there!");
				sock.receive(function (dat) {
					trace(dat);
				});
			});
		});
	}
/*
	static function mains() {
	#if flash
		var sock = new XMLSocket();
		sock.addEventListener(flash.events.Event.CONNECT, function(ev) {
			trace("CONNECT");
		});
		sock.addEventListener(flash.events.DataEvent.DATA, function(ev) {
			trace("RECEIVE "+ev.data);
		});
		sock.addEventListener(flash.events.Event.CLOSE, function(ev) {
			trace("CLOSED");
		});
		sock.addEventListener(flash.events.IOErrorEvent.IO_ERROR, function(_) {
			trace("IO_ERR");
		});
		sock.addEventListener(flash.events.ProgressEvent.PROGRESS, function(ev) {
			trace("PROGRESS");
		});
		sock.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, function(ev) {
			trace("S_ERR");
		});

		sock.connect("localhost",4569);

		sock.send("hello there!");
	#elseif cpp
		var sock = new Socket();
		sock.connect(new cpp.net.Host("localhost"),4569);

	//	trace(sock.read());
		trace(sock.input.readUntil(0));
		sock.write("hello there!");
		trace(sock.input.readUntil(0));
	//	trace(sock.read());
	#end
	}*/
}
