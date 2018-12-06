package hx.ws;

class Log {
    public static inline var INFO:Int =  0x000001;
    public static inline var DEBUG:Int = 0x000010;
    public static inline var DATA:Int =  0x000100;
    
    public static var mask:Int = 0;
    
    public static function info(data:String, id:Null<Int> = null) {
        if (mask & INFO != INFO) {
            return;
        }
        
        if (id != null) {
            Sys.println('INFO  :: ID-${id} :: ${data}');
        } else {
            Sys.println('INFO  :: ${data}');
        }
    }
    
    public static function debug(data:String, id:Null<Int> = null) {
        if (mask & DEBUG != DEBUG) {
            return;
        }
        
        if (id != null) {
            Sys.println('DEBUG :: ID-${id} :: ${data}');
        } else {
            Sys.println('DEBUG :: ${data}');
        }
    }
    
    public static function data(data:String, id:Null<Int> = null) {
        if (mask & DATA != DATA) {
            return;
        }
        
        if (id != null) {
            Sys.println('DATA  :: ID-${id}\n------------------------------\n${data}\n------------------------------');
        } else {
            Sys.println('${data}');
        }
    }
}
