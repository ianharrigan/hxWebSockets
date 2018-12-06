package hx.ws;

enum HandlerState {
    Handshake;
    Head;
    HeadExtraLength;
    HeadExtraMask;
    Body;
    Closed;
}
