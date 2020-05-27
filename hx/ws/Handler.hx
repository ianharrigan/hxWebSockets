package hx.ws;

class Handler extends WebSocketCommon {
    public function new(socket:SocketImpl) {
        super(socket);
        isClient = false;
    }

    public function handle() {
        process();
    }
}
