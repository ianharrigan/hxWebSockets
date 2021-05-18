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

### Secure server

`Main.hx`
```haxe
package;

import hx.ws.WebSocketSecureServer;

import sys.ssl.Key;
import sys.ssl.Certificate;


class Main
{

    public static function main()
    {
        // self signed ceritificate
        var cert = Certificate.loadFile('example.cert');
        var key = Key.loadFile('example.key');

        var server = new WebSocketSecureServer<SocketHandler>("0.0.0.0", 5000,
            cert, // actual certificate
            key,  // key to the certificate
            cert, // certificate chain to aid clients finding way to trusted root,
                  // pass cert in case of selfsigned
            10);
        server.start();
    }
}
```

Initialize client with `wss` protocol, e.g. `new WebSocket("wss://localhost:5000");`

### Accepting selfsigned certs

Only on sys platforms, since they expose SslSocket. If you need to test JS with selfsigned certs, you need to import certificate into your browser trusted collection.

```haxe
import hx.ws.Log;
import hx.ws.WebSocket;

import hx.ws.SocketImpl;
import hx.ws.SecureSocketImpl;

class WebSocketNoVerify extends WebSocket {
    override private function createSocket():SocketImpl
    {
        if (_protocol == "wss") {
            var socket:SecureSocketImpl = cast super.createSocket();
            socket.verifyCert = false;
            return socket;
        }
        return super.createSocket();
    }
}

class Main {
    static function main() {
        Log.mask = Log.INFO | Log.DEBUG | Log.DATA;
        var ws = new WebSocketNoVerify("wss://localhost:5000");
        ws.onopen = function() {
            ws.send("alice string");
        }
        Sys.getChar(true);
    }
}
```
