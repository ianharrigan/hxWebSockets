package;

import hx.ws.Log;
import hx.ws.WebSocket;

class Main {
    static function main() {
        Log.mask = Log.INFO | Log.DEBUG | Log.DATA;
        var ws = new WebSocket("ws://localhost:5000");

        ws.onopen = function() {
            ws.send("bob");
        }

        Sys.getChar(true);
    }
}