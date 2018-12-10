package hx.ws;

#if js 

typedef WebSocket = js.html.WebSocket;

#elseif sys

#if neko
import neko.vm.Thread;
#elseif cpp
import cpp.vm.Thread;
#end

import haxe.crypto.Base64;
import haxe.io.Bytes;

class WebSocket extends WebSocketCommon {
    public var _host:String;
    public var _port:Int;
    
    private var _processThread:Thread;
    private var _key:String = "wskey";
    private var _encodedKey:String = "wskey";
    
    public function new(uri:String) {
        super();
        
        var uriRegExp = ~/^(\w+?):\/\/([\w\.-]+)(:(\d+))?(\/.*)?$/;
        if (!uriRegExp.match(uri)) throw 'Uri not matching websocket uri "${uri}"';
        
        _host = uriRegExp.matched(2);
        _port = Std.parseInt(uriRegExp.matched(4));
        _socket.connect(new sys.net.Host(_host), _port);
        
        _processThread = Thread.create(processThread);
        _processThread.sendMessage(this);
        
        sendHandshake();
    }
    
    private function processThread() {
        var ws:WebSocket = Thread.readMessage(true);
        Log.debug("Thread started", ws.id);
        while (ws.state != State.Closed) { // TODO: should think about mutex
            ws.process();
            Sys.sleep(.01);
        }
        Log.debug("Thread ended", ws.id);
    }
    
    public function sendHandshake() {
        var httpRequest = new HttpRequest();
        httpRequest.method = "GET";
        httpRequest.uri = "/";
        httpRequest.httpVersion = "HTTP/1.1";
        
        httpRequest.headers.set(HttpHeader.HOST, _socket.host().host.toString() + ":" + _socket.host().port);
        httpRequest.headers.set(HttpHeader.USER_AGENT, "hxWebSockets");
        httpRequest.headers.set(HttpHeader.SEC_WEBSOSCKET_VERSION, "13");
        httpRequest.headers.set(HttpHeader.UPGRADE, "websocket");
        httpRequest.headers.set(HttpHeader.CONNECTION, "Upgrade");
        httpRequest.headers.set(HttpHeader.PRAGMA, "no-cache");
        httpRequest.headers.set(HttpHeader.CACHE_CONTROL, "no-cache");
        httpRequest.headers.set(HttpHeader.ORIGIN, _socket.host().host.toString() + ":" + _socket.host().port);
        _encodedKey = Base64.encode(Utf8Encoder.encode(_key));
        httpRequest.headers.set(HttpHeader.SEC_WEBSOCKET_KEY, _encodedKey);
        
        sendHttpRequest(httpRequest);
    }
    
    private override function handleData() {
        switch (state) {
            case State.Handshake:
                var httpResponse = recvHttpResponse();
                if (httpResponse == null) {
                    return;
                }
                
                handshake(httpResponse);
                handleData();
            case _:
                super.handleData();
        }
                
    }
    
    private function handshake(httpResponse:HttpResponse) {
        trace(httpResponse.toString());
        if (httpResponse.code != 101) {
            if (onerror != null) {
                onerror(httpResponse.headers.get(HttpHeader.X_WEBSOCKET_REJECT_REASON));
            }
            close();
            return;
        }
        
        var secKey = httpResponse.headers.get(HttpHeader.SEC_WEBSOSCKET_ACCEPT);
        if (secKey != makeWSKey(_encodedKey)) {
            if (onerror != null) {
                onerror("Error during WebSocket handshake: Incorrect 'Sec-WebSocket-Accept' header value");
            }
            close();
            return;
        }

        _onopenCalled = false;
        state = State.Head;
    }
}

#end