package hx.ws;

class Handler extends WebSocketCommon {
    public var validateHandshake:(HttpRequest, HttpResponse) -> HttpResponse = null;
    public function new(socket:SocketImpl) {
        super(socket);
        isClient = false;
    }

    public function handle() {
        process();
    }
}
