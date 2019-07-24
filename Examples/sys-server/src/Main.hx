package;

import hx.ws.Log;
import hx.ws.WebSocketServer;

class Main  {
    static function main()  {
        Log.mask = Log.INFO | Log.DEBUG | Log.DATA;
        var server = new WebSocketServer<MyHandler>("localhost", 5000, 10);
        server.start();
    }
}
