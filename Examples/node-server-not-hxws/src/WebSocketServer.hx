package;

@:jsRequire("websocket", "server")
extern class WebSocketServer {
    public function new(options:Dynamic);
    public function on(event:String, fb:Dynamic):Void;
}