package ws.html;
import js.html.WebSocket;

//import haxe.net.WebSocket;

class Main {
	public static function main() {
        
        for (a in 0...3) {
            var client = new TestClient();
        }
        
        
        /*
        trace('testing!');
        var ws = WebSocket.create("ws://localhost:8000/", null, false);
        ws.onopen = function() {
            trace('open!');
            ws.sendString('hello friend!');
            ws.sendString('hello my dearest friend! this is a longer message! which is longer than 126 bytes, so it sends a short instead of just a single byte. And yeah, it should be longer thant that by now!');
            var s = 'message longer than 64k';
            while(s.length < 100000) s = '$s, $s';
            ws.sendString(s);
            ws.sendString('message length was ${s.length}');
            
        };
        ws.onmessageString = function(message) {
            trace('message from server!' + (message.length > 200 ? message.substr(0, 200) + '...' : message));
            trace('message.length=' + message.length);
        };

        #if sys
        while (true) {
            ws.process();
            Sys.sleep(0.1);
        }
        #end
        */
	}
}