package;

import haxe.ui.containers.VBox;
import hx.ws.WebSocket;

@:build(haxe.ui.macros.ComponentMacros.build("assets/client.xml"))
class Client extends VBox {
    public var clientId:Int;
    
    private var _ws:WebSocket;
    
    public function new(id:Int = -1) {
        super();
        percentWidth = 100;
        clientId = id;
        updateInfo();
        
        var s = "Test data";
        #if haxeui_hxwidgets
        s += " from haxeui-hxwidgts";
        #elseif haxeui_html5
        s += " from haxeui-html5";
        #end
        s += " client " + id;
        sendText.text = s;
        
        connectButton.onClick = function(e) {
            connect();
        }
        
        disconnectButton.onClick = function(e) {
            disconnect();
        }
        
        sendButton.onClick = function(e) {
            sendString(sendText.text);
        }
        
        logText.text = "";
        recvText.text = "";
        log("ready");
    }
    
    public function updateInfo() {
        var s = "Client " + clientId;
        if (_ws != null) {
            s += " - connected";
            infoLabel.color = 0x00FF00;
            infoLabel.backgroundColor = 0x008800;
        } else {
            s += " - disconnected";
            infoLabel.color = 0xFF0000;
            infoLabel.backgroundColor = 0x880000;
        }
        infoLabel.text = s;
    }
    
    public function sendString(s:String) {
        log("sending string: len = " + s.length);
        if (_ws == null) {
            log("error: not connected");
            return;
        }
        _ws.send(s);
    }
    
    public function connect() {
        log("connecting");
        _ws = new WebSocket(uri.text);
        _ws.onopen = function() {
            log("connected");
            updateInfo();
        };
        _ws.onmessage = function(msg:Dynamic) {
            log("data received: " + msg);
            recvText.text = msg.data;
        };
        _ws.onclose = function() {
            _ws = null;
            log("disconnected");
            updateInfo();
        };  
        _ws.onerror = function(err) {
            //js.Browser.console.log(err);
            log("error: " + err.toString());
        }
    }
    
    public function disconnect() {
        _ws.close();
        _ws = null;
    }
    
    private var _logData:String = "";
    public function log(s:String) {
        _logData += s + "\r\n";
        logText.text = _logData;
    }
}    
