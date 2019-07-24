package hx.ws;

#if java

typedef SocketImpl = hx.ws.java.NioSocket;

#else

typedef SocketImpl = sys.net.Socket;

#end