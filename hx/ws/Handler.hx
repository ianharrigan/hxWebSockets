package hx.ws;

class Handler extends WebSocketCommon {
    public var validateHandshake:(HttpRequest, HttpResponse, (HttpResponse) -> Void) -> Void = null;

    public function new(socket:SocketImpl) {
        super(socket);
        isClient = false;
    }

    public function handle() {
        process();
    }
}
