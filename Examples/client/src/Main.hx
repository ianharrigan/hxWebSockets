package;

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
