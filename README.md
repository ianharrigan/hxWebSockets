# hxWebSockets
###### Fork of https://github.com/soywiz/haxe-ws

Haxe Websockets supporting the following targets:
- C++
- HashLink
- JavaScript

Incomplete support for Java and C#.

# Examples

### Client

```haxe
import haxe.io.Bytes;
import hx.ws.Log;
import hx.ws.WebSocket;
class Main {
    static function main() {
        Log.mask = Log.INFO | Log.DEBUG | Log.DATA;
        var ws = new WebSocket("ws://localhost:5000");
        ws.onopen = function() {
            ws.send("alice string");
            ws.send(Bytes.ofString("alice bytes"));
        }
        #if sys
        Sys.getChar(true);
        #end
    }
}
```

### Server

`Main.hx`
```haxe
import hx.ws.Log;
import hx.ws.WebSocketServer;
class Main {
    static function main() {
        Log.mask = Log.INFO | Log.DEBUG | Log.DATA;
        var server = new WebSocketServer<MyHandler>("localhost", 5000, 10);
        server.start();
    }
}
```

`MyHandler.hx`
```haxe
import hx.ws.SocketImpl;
import hx.ws.WebSocketHandler;
import hx.ws.Types;
class MyHandler extends WebSocketHandler {
    public function new(s: SocketImpl) {
        super(s);
        onopen = function() {
            trace(id + ". OPEN");
        }
        onclose = function() {
            trace(id + ". CLOSE");
        }
        onmessage = function(message: MessageType) {
            switch (message) {
                case BytesMessage(content):
                    trace(content.readAllAvailableBytes());
                case StrMessage(content):
                    var str = "echo: " + content;
                    trace(str);
                    send(str);
            }
        }
        onerror = function(error) {
            trace(id + ". ERROR: " + error);
        }
    }
}
```
