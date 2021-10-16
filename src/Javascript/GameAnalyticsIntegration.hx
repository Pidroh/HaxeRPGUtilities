import js.Syntax;

class GameAnalyticsIntegration{
    
    public static function InitializeCheck(){
        var gameKey = "3465b32dba81c3effc66d8193e69e762";
        var secretKey = "0542cc0026b566e59c853ee0a8b7b67680858018";
        Syntax.code('
        if(gameanalytics.GameAnalytics != null && gaInited == false){
            gaInited = true;
            gameanalytics.GameAnalytics.initialize({0},{1}); 
            gameanalytics.GameAnalytics.configureBuild({2});
        }
        ', gameKey, secretKey, "0.3.0");    
    }

    public static function SendDesignEvent(eventName:String, value:Int){
        Syntax.code('
        gameanalytics.GameAnalytics.addDesignEvent({0}, {1});
        ', eventName, value);
    }
}