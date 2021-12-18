package hx.ws;

import haxe.Constraints;
import haxe.MainLoop;
import haxe.io.Error;

@:generic
class WebSocketServer
    #if (haxe_ver < 4)
    <T:(Constructible<SocketImpl->Void>, Handler)> {
    #else
    <T:Constructible<SocketImpl->Void> & Handler> {
    #end

    private var _serverSocket:SocketImpl;

    private var _host:String;
    private var _port:Int;
    private var _maxConnections:Int;

    public var handlers:Array<T> = [];

    private var _stopServer:Bool = false;
    public var sleepAmount:Float = 0.01;

    public var onClientAdded:T->Void = null;
    public var onClientRemoved:T->Void = null;

    public function new(host:String, port:Int, maxConnections:Int = 1) {
        _host = host;
        _port = port;
        _maxConnections = maxConnections;
    }

    private function createSocket() {
        return new SocketImpl();
    }

    public function sendAll(data:Any) {
        for (h in handlers) {
            h.send(data);
        }
    }
    
    public function start() {
        _stopServer = false;

        _serverSocket = createSocket();
        _serverSocket.setBlocking(false);
        _serverSocket.bind(new sys.net.Host(_host), _port);
        _serverSocket.listen(_maxConnections);
        Log.info('Starting server - ${_host}:${_port} (maxConnections: ${_maxConnections})');

        #if cs

        while (true) {
            var continueLoop = tick();
            if (continueLoop == false) {
                break;
            }

            Sys.sleep(sleepAmount);
        }

        #elseif threaded_server

        MainLoop.addThread(function() {
            while (true) {
                var continueLoop = tick();
                if (continueLoop == false) {
                    break;
                }

                Sys.sleep(sleepAmount);
            }
        });
        
        #else

        MainLoop.add(function() {
            tick();
            Sys.sleep(sleepAmount);
        });

        #end
    }

    private function handleNewSocket(socket) {
        var handler = new T(socket);
        handlers.push(handler);

        Log.debug("Adding to web server handler to list - total: " + handlers.length, handler.id);
        if (onClientAdded != null) {
            onClientAdded(handler);
        }
    }

    public function tick() {
        if (_stopServer == true) {
            for (h in handlers) {
                h.close();
            }
            handlers = [];
            try {
                _serverSocket.close();
            } catch (e:Dynamic) { }
            return false;
        }

        try {
            var clientSocket:SocketImpl = _serverSocket.accept();
            if (clientSocket != null) { // HL doesnt throw blocking, instead returns null
                handleNewSocket(clientSocket);
            }
        } catch (e:Dynamic) {
            if (e != 'Blocking' && e != Error.Blocked) {
                throw(e);
            }
        }

        for (h in handlers) {
            h.handle();
        }

        var toRemove = [];
        for (h in handlers) {
            if (h.state == State.Closed) {
                toRemove.push(h);
            }
        }

        for (h in toRemove) {
            handlers.remove(h);
            Log.debug("Removing web server handler from list - total: " + handlers.length, h.id);
            if (onClientRemoved != null) {
                onClientRemoved(h);
            }
        }

        return true;
    }

    public function stop() {
        _stopServer = true;
    }

    public function totalHandlers(): Int {
        return handlers.length;
    }
}
