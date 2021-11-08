import js.Syntax;

class GameAnalyticsIntegration{
    
    public static function InitializeCheck(){
        var gameKey = "3465b32dba81c3effc66d8193e69e762";
        var secretKey = "0542cc0026b566e59c853ee0a8b7b67680858018";
        Syntax.code('
        if(gameanalytics.GameAnalytics != null && gaInited == false){
            gaInited = true;
            gameanalytics.GameAnalytics.configureBuild({2});
            gameanalytics.GameAnalytics.initialize({0},{1}); 
            
        }
        ', gameKey, secretKey, "0.8.0dev");
    }

    public static function SendDesignEvent(eventName:String, value:Int){
        Syntax.code('
        gameanalytics.GameAnalytics.addDesignEvent({0}, {1});
        ', eventName, value);
    }

    public static function SendProgressStartEvent(prog1, prog2="", prog3=""){
        Syntax.code('
        gameanalytics.GameAnalytics.addProgressionEvent(gameanalytics.EGAProgressionStatus.Start, {0}, {1}, {2});
        ', prog1, prog2, prog3);
    }
    public static function SendProgressCompleteEvent(prog1, prog2="", prog3=""){
        Syntax.code('
        gameanalytics.GameAnalytics.addProgressionEvent(gameanalytics.EGAProgressionStatus.Complete, {0}, {1}, {2});
        ', prog1, prog2, prog3);
    }

    public static function SendProgressFailEvent(prog1, prog2="", prog3=""){
        Syntax.code('
        gameanalytics.GameAnalytics.addProgressionEvent(gameanalytics.EGAProgressionStatus.Fail, {0}, {1}, {2});
        ', prog1, prog2, prog3);
    }
}