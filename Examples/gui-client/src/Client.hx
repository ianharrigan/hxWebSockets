package;

import haxe.Resource;
import haxe.io.Bytes;
import haxe.ui.ToolkitAssets;
import haxe.ui.assets.ImageInfo;
import haxe.ui.components.Image;
import haxe.ui.containers.VBox;
import haxe.ui.core.ImageDisplay;
import hx.ws.Buffer;
import hx.ws.WebSocket;
import hx.ws.BinaryType;

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

        sendLargeButton.onClick = function(e) {
            sendString('hello my dearest friend! this is a longer message! which is longer than 126 bytes, so it sends a short instead of just a single byte. And yeah, it should be longer thant that by now!');
        }

        sendHugeButton.onClick = function(e) {
            var s = 'message longer than 64k';
            while(s.length < 100000) s = '$s, $s';
            sendString(s);
        }

        sendBinaryButton.onClick = function(e) {
            var bytes = Resource.getBytes("haxeui-core/styles/default/haxeui.png");
            sendBinary(bytes);
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

        if (_ws.binaryType == BinaryType.ARRAYBUFFER) {
            var buffer = new Buffer();
            buffer.writeBytes(Bytes.ofString(s));
            _ws.send(buffer);
        } else {
            _ws.send(s);
        }
    }

    public function sendBinary(b:Bytes) {
        log("sending binary: len = " + b.length);
        if (_ws == null) {
            log("error: not connected");
            return;
        }

        var buffer = new Buffer();
        buffer.writeBytes(b);
        _ws.send(buffer);
    }

    public function connect() {
        log("connecting");
        _ws = new WebSocket(uri.text);
        if (binaryCheck.selected == true) {
            _ws.binaryType = BinaryType.ARRAYBUFFER;
        }
        _ws.onopen = function() {
            log("connected");
            updateInfo();
        };
        _ws.onmessage = function(msg:Dynamic) {
            log("data received: len = " + msg.data.length + ", type = " + msg.type);
            recvText.text = msg.data;
            if (msg.type == "binary") {
                showImage(msg.data.readAllAvailableBytes());
            }
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

    private function showImage(bytes:Bytes) {
        // TODO: all a little bit hacky - would be nice if image could handle this internally and just create image from bytes directly
        // all the functions are there, just not linked up - haxeui enhancment, nothing to do with hxWebSockets
        ToolkitAssets.instance.imageFromBytes(bytes, function(imageInfo:ImageInfo) {
            if (imageInfo != null) {
                trace(imageInfo.width + "x" + imageInfo.height);
                var image:Image = binaryImageResult;
                var display:ImageDisplay = image.getImageDisplay();
                if (display != null) {
                    #if haxeui_hxwidgets
                        var bmp:hx.widgets.StaticBitmap = cast image.window;
                        bmp.bitmap = imageInfo.data;
                        if (bmp.parent != null) {
                            bmp.parent.refresh(); // if bitmap has resized, get rid of any left of artifacts from parent (wx thang!)
                        }
                        image.invalidateComponentLayout();
                    #end

                    display.imageInfo = imageInfo;
                    image.originalWidth = imageInfo.width;
                    image.originalHeight = imageInfo.height;
                    if (image.autoSize() == true && image.parentComponent != null) {
                        image.parentComponent.invalidateComponentLayout();
                    }
                    image.invalidateComponent();
                    display.validateComponent();
                }
            } else {
                trace("Not an image");
            }
        });
    }

    private var _logData:String = "";
    public function log(s:String) {
        _logData += s + "\r\n";
        logText.text = _logData;
    }
}
