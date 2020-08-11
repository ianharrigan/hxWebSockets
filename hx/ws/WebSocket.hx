package hx.ws;

import hx.ws.Types;

#if js

import haxe.Constraints.Function;
import haxe.io.Bytes;

#if (haxe_ver < 4)
    typedef JsBuffer = js.html.ArrayBuffer;
#else
    typedef JsBuffer = js.lib.ArrayBuffer;
#end

class WebSocket { // lets use composition so we can intercept send / onmessage and convert to something haxey if its binary
    private var _url:String;
    private var _ws:js.html.WebSocket = null;

    public function new(url:String, immediateOpen=true) {
        _url = url;
        if (immediateOpen) {
            open();
        }
    }

    public function open() {
        if (_ws != null) {
            throw "Socket already connected";
        }
        _ws = new js.html.WebSocket(_url);
    }

    public var onopen(get, set):Function;
    private function get_onopen():Function {
        return _ws.onopen;
    }
    private function set_onopen(value:Function):Function {
        _ws.onopen = value;
        return value;
    }

    public var onclose(get, set):Function;
    private function get_onclose():Function {
        return _ws.onclose;
    }
    private function set_onclose(value:Function):Function {
        _ws.onclose = value;
        return value;
    }

    public var onerror(get, set):Function;
    private function get_onerror():Function {
        return _ws.onerror;
    }
    private function set_onerror(value:Function):Function {
        _ws.onerror = value;
        return value;
    }

    private var _onmessage:Function = null;
    public var onmessage(get, set):Function;
    private function get_onmessage():Function {
        return _onmessage;
    }
    private function set_onmessage(value:Function):Function {
        _onmessage = value;
        _ws.onmessage = function(message: Dynamic) {
            if (_onmessage != null) {
                if (Std.is(message.data, JsBuffer)) {
                    var buffer = new Buffer();
                    buffer.writeBytes(Bytes.ofData(message.data));
                    _onmessage(BytesMessage(buffer));
                } else {
                    _onmessage(StrMessage(message));
                }
            }
        };
        return value;
    }

    public var binaryType(get, set):BinaryType;
    private function get_binaryType() {
        return _ws.binaryType;
    }
    private function set_binaryType(value:BinaryType):BinaryType {
        _ws.binaryType = value;
        return value;
    }

    public function close() {
        _ws.close();
    }

    public function send(data:Any) {
        if (Std.is(data, Buffer)) {
            var buffer = cast(data, Buffer);
            _ws.send(buffer.readAllAvailableBytes().getData());
        } else {
            _ws.send(data);
        }
    }
}

#elseif sys


#if (haxe_ver >= 4)
import sys.thread.Thread;
#elseif neko
import neko.vm.Thread;
#elseif cpp
import cpp.vm.Thread;
#end

import haxe.crypto.Base64;
import haxe.io.Bytes;

class WebSocket extends WebSocketCommon {
    public var _host:String;
    public var _port:Int;
    public var _uri:String;

    private var _processThread:Thread;
    private var _encodedKey:String = "wskey";

    public var binaryType:BinaryType;

    public var additionalHeaders(get, null):Map<String, String>;

    public function new(uri:String, immediateOpen=true) {
        var uriRegExp = ~/^(\w+?):\/\/([\w\.-]+)(:(\d+))?(\/.*)?$/;

        if ( ! uriRegExp.match(uri)) throw 'Uri not matching websocket uri "${uri}"';

        var proto = uriRegExp.matched(1);
        if (proto == "wss") {
            #if (java || cs)

            throw "Secure sockets not implemented";

            #else

            _port = 443;
            var s = new SecureSocketImpl();
            super(s);

            #end
        } else if (proto == "ws") {
            _port = 80;
            super();
        } else {
            throw 'Unknown protocol $proto';
        }

        _host = uriRegExp.matched(2);
        var parsedPort = Std.parseInt(uriRegExp.matched(4));
        if (parsedPort > 0 ) {
            _port = parsedPort;
        }
        _uri = uriRegExp.matched(5);
        if (_uri == null || _uri.length == 0) {
            _uri = "/";
        }

        if (immediateOpen) {
            open();
        }
    }


    public function open() {
        if (state != State.Handshake) {
            throw "Socket already connected";
        }
        _socket.setBlocking(true);
        _socket.connect(new sys.net.Host(_host), _port);
        _socket.setBlocking(false);

        #if !cs

        _processThread = Thread.create(processThread);
        _processThread.sendMessage(this);

        #else

        haxe.MainLoop.addThread(function() {
            Log.debug("Thread started", this.id);
            processLoop(this);
            Log.debug("Thread ended", this.id);
        });

        #end

        sendHandshake();
    }

    private function processThread() {
        Log.debug("Thread started", this.id);
        var ws:WebSocket = Thread.readMessage(true);
        processLoop(this);
        Log.debug("Thread ended", this.id);
    }

    private function processLoop(ws:WebSocket) {
        while (ws.state != State.Closed) { // TODO: should think about mutex
            ws.process();
            Sys.sleep(.01);
        }
    }

    function get_additionalHeaders() {
        if (additionalHeaders == null) {
            additionalHeaders = new Map<String, String>();
        }
        return additionalHeaders;
    }

    public function sendHandshake() {
        var httpRequest = new HttpRequest();
        httpRequest.method = "GET";
        httpRequest.uri = _uri;
        httpRequest.httpVersion = "HTTP/1.1";

        httpRequest.headers.set(HttpHeader.HOST, _host + ":" + _port);
        httpRequest.headers.set(HttpHeader.USER_AGENT, "hxWebSockets");
        httpRequest.headers.set(HttpHeader.SEC_WEBSOSCKET_VERSION, "13");
        httpRequest.headers.set(HttpHeader.UPGRADE, "websocket");
        httpRequest.headers.set(HttpHeader.CONNECTION, "Upgrade");
        httpRequest.headers.set(HttpHeader.PRAGMA, "no-cache");
        httpRequest.headers.set(HttpHeader.CACHE_CONTROL, "no-cache");
        httpRequest.headers.set(HttpHeader.ORIGIN, _socket.host().host.toString() + ":" + _socket.host().port);

        _encodedKey = generateWSKey();
        httpRequest.headers.set(HttpHeader.SEC_WEBSOCKET_KEY, _encodedKey);

        if (additionalHeaders != null) {
            for ( k in additionalHeaders.keys()) {
                httpRequest.headers.set(k, additionalHeaders[k]);
            }
        }

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
        if (httpResponse.code != 101) {
            if (onerror != null) {
                onerror(httpResponse.headers.get(HttpHeader.X_WEBSOCKET_REJECT_REASON));
            }
            close();
            return;
        }

        var secKey = httpResponse.headers.get(HttpHeader.SEC_WEBSOSCKET_ACCEPT);
        if (secKey != makeWSKeyResponse(_encodedKey)) {
            if (onerror != null) {
                onerror("Error during WebSocket handshake: Incorrect 'Sec-WebSocket-Accept' header value");
            }
            close();
            return;
        }

        _onopenCalled = false;
        state = State.Head;
    }

    private function generateWSKey():String {
        var b = Bytes.alloc(16);
        for (i in 0...16) {
            b.set(i, Std.random(255));
        }
        return Base64.encode(b);
    }
}

#end