package;

import js.Node;

// this server is using node module "websockets"
// and is mainly here to ensure client
// sockets are behaving correctly
// based on: https://medium.com/@martin.sikora/node-js-websocket-simple-chat-tutorial-2def3a841b61
class Main {
    static function main() {
        //var WebSocketServer:Dynamic = Node.require("websocket").server;
        var http = Node.require('http');

        var server = http.createServer(function(request, response) {
          // process HTTP request. Since we're writing just WebSockets
          // server we don't have to implement anything.
        });
        server.listen(5000, function() { });
        trace("server started on port 5000");

        // create the server
        var wsServer = new WebSocketServer({
          httpServer: server
        });

        // WebSocket server
        wsServer.on('request', function(request) {
          trace("GOT CONNECTION");
          var connection = request.accept(null, request.origin);

          // This is the most important callback for us, we'll handle
          // all messages from users here.
          connection.on('message', function(message) {
            if (message.type == 'utf8') {
              // process WebSocket message
              trace("Echoing message: " + message.utf8Data);
              connection.sendUTF("echo: " + message.utf8Data);
            }
          });

          connection.on('close', function(connection) {
            // close user connection
          });
        });
    }
}