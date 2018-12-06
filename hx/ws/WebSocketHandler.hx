package hx.ws;

import haxe.crypto.Base64;
import haxe.crypto.Sha1;
import haxe.io.Bytes;

class WebSocketHandler extends Handler {
    public function new(socket:SocketImpl) {
        super(socket);
        _socket.setBlocking(false);
        Log.debug('New socket handler', id);
    }
    
    private override function handleData() {
        switch (state) {
            case HandlerState.Handshake:
                var httpRequest = recvHttpRequest();
                if (httpRequest == null) {
                    return;
                }
                
                handshake(httpRequest);
                handleData();
            case _:
                super.handleData();
        }
    }
    
    public function handshake(httpRequest:HttpRequest) {
        Log.debug('Handshaking', id);
        var key = httpRequest.headers.get(HttpHeader.SEC_WEBSOCKET_KEY);
        var result = Base64.encode(Sha1.make(Bytes.ofString(key + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')));
        Log.debug('Handshaking key - ${result}', id);
        
        var httpResponse = new HttpResponse();
        httpResponse.code = 101;
        httpResponse.text = "Switching Protocols";
        httpResponse.headers.set(HttpHeader.UPGRADE, "websocket");
        httpResponse.headers.set(HttpHeader.CONNECTION, "Upgrade");
        httpResponse.headers.set(HttpHeader.SEC_WEBSOSCKET_ACCEPT, result);
        sendHttpResponse(httpResponse);
        
        state = HandlerState.Head;
        Log.debug('Connected', id);
    }
}