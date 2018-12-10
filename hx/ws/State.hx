package hx.ws;

enum State {
    Handshake;
    Head;
    HeadExtraLength;
    HeadExtraMask;
    Body;
    Closed;
}
