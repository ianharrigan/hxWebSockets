package hx.ws;

import haxe.Constraints;
import haxe.io.Error;

@:generic
class WebSocketServer
    #if (haxe_ver < 4)
    <T:(Constructible<SocketImpl->Void>, Handler)> {
    #else
    <T:Constructible<SocketImpl->Void> & Handler> {
    #end
    
    private var _serverSocket:SocketImpl;
    private var _handlers:Array<T> = [];
    
    private var _host:String;
    private var _port:Int;
    private var _maxConnections:Int;
    
    private var _stopServer:Bool = false;
    
    public function new(host:String, port:Int, maxConnections:Int = 1) {
        _host = host;
        _port = port;
        _maxConnections = maxConnections;
    }
    
    public function start() {
        _stopServer = false;
        
        _serverSocket = new SocketImpl();
        _serverSocket.setBlocking(false);
        _serverSocket.bind(new sys.net.Host(_host), _port);
        _serverSocket.listen(_maxConnections);
        Log.info('Starting server - ${_host}:${_port} (maxConnections: ${_maxConnections})');
        
        while (true) {
            if (_stopServer == true) {
                for (h in _handlers) {
                    h.close();
                }
                _handlers = [];
                try {
                    _serverSocket.close();
                } catch (e:Dynamic) { }
                break;
            }
            
            try {
                var clientSocket:SocketImpl = _serverSocket.accept();
                var handler = new T(clientSocket);
                _handlers.push(handler);
                Log.debug("Adding to web server handler to list - total: " + _handlers.length, handler.id);
            } catch (e:Dynamic) {
                if (e != 'Blocking' && e != Error.Blocked) {
                    throw(e);
                }
            }
            
            for (h in _handlers) {
                h.handle();
            }
            
            var toRemove = [];
            for (h in _handlers) {
                if (h.state == HandlerState.Closed) {
                    toRemove.push(h);
                }
            }
            
            for (h in toRemove) {
                _handlers.remove(h);
                Log.debug("Removing web server handler from list - total: " + _handlers.length, h.id);
            }
            
            Sys.sleep(0.01);
        }
    }
    
    public function stop() {
        _stopServer = true;
    }
}
