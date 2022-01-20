package hx.ws;
import hx.ws.uuid.Uuid;

class Util {
    public static function generateUUID():String {
        return Uuid.v1();
    }
}