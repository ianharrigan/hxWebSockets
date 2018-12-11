package;

import hx.ws.SocketImpl;
import hx.ws.WebSocketHandler;

class MyHandler extends WebSocketHandler {
    public function new(s:SocketImpl) {
        super(s);
        onopen = function() {
            trace(id + ". OPEN");
        }
        onclose = function() {
            trace(id + ". CLOSE");
        }
        onmessage = function(message) {
            trace(id + ". DATA: " + message.data.length + ", " + message.type);
            if (message.type == "text") {
                send("echo: " + message.data);
            } else {
                send(message.data);
            }
        }
        onerror = function(error) {
            trace(id + ". ERROR: " + error);
        }
    }
}