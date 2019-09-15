package hx.ws;

#if java

typedef SocketImpl = hx.ws.java.NioSocket;

#elseif cs

typedef SocketImpl = hx.ws.cs.NonBlockingSocket;

#elseif nodejs

typedef SocketImpl = hx.ws.nodejs.NodeSocket;

#else

typedef SocketImpl = sys.net.Socket;

#end