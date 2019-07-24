package ws.html;
import js.Browser;
import js.html.DivElement;
import js.html.TextAreaElement;
import js.html.WebSocket;

class TestClient {
    private static var nextId:Int = 0;
    public var id:Int = 0;

    private var _info:DivElement;
    private var _send:TextAreaElement;
    private var _recv:TextAreaElement;
    private var _log:TextAreaElement;

    private var _ws:WebSocket;

    public function new() {
        id = ++nextId;

        _info = Browser.document.createDivElement();
        Browser.document.body.appendChild(_info);


        var button = Browser.document.createButtonElement();
        button.innerText = "Connect";
        button.onclick = function(e) {
            connnect();
        }
        Browser.document.body.appendChild(button);

        var button = Browser.document.createButtonElement();
        button.innerText = "Disconnect";
        button.onclick = function(e) {
            _ws.close();
            _ws = null;
        }
        Browser.document.body.appendChild(button);

        Browser.document.body.appendChild(Browser.document.createBRElement());

        _send = Browser.document.createTextAreaElement();
        _send.value = "from client " + id;
        _send.style.width = "200px";
        _send.style.height = "100px";
        Browser.document.body.appendChild(_send);

        _recv = Browser.document.createTextAreaElement();
        _recv.style.width = "200px";
        _recv.style.height = "100px";
        Browser.document.body.appendChild(_recv);

        _log = Browser.document.createTextAreaElement();
        _log.style.width = "400px";
        _log.style.height = "100px";
        Browser.document.body.appendChild(_log);

        Browser.document.body.appendChild(Browser.document.createBRElement());

        var button = Browser.document.createButtonElement();
        button.innerText = "Send";
        button.onclick = function(e) {
            sendString(_send.value);
        }
        Browser.document.body.appendChild(button);

        var hr = Browser.document.createHRElement();
        Browser.document.body.appendChild(hr);

        log("ready");
        init();
        updateInfo();
    }

    public function init() {
    }

    public function connnect() {
        log("connecting");
        try {
            _ws = new WebSocket("ws://localhost:5000");
            _ws.onopen = function() {
                log("connected");
                updateInfo();
            };
            _ws.onmessage = function(msg:Dynamic) {
                log("data received: " + msg);
                _recv.innerText = msg.data;
            };
            _ws.onclose = function() {
                _ws = null;
                log("disconnected");
                updateInfo();
            };
            _ws.onerror = function(err) {
                log("error: " + err.toString());
            }
        } catch (err:Dynamic) {
            log("Exception: " + err);
        }
    }

    public function sendString(s:String) {
        log("sending string: len = " + s.length);
        if (_ws == null) {
            log("error: not connected");
            return;
        }
        _ws.send(s);
    }

    public function updateInfo() {
        var info = "Client " + id;
        if (_ws != null) {
            info += " - connected";
        } else {
            info += " - disonnected";
        }
        _info.innerHTML = info;
    }

    private function log(data:String) {
        _log.value += data + "\r\n";
        _log.scrollTop = _log.scrollHeight;
    }
}