package hx.ws;

class Handler extends WebSocketCommon {
    public function new(socket:SocketImpl) {
        super(socket);
    }

    public function handle() {
        process();
    }
}
