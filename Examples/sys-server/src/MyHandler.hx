package;

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
                    var str = "echo: " + content.readAllAvailableBytes();
                    trace(str);
                    send(str);
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
