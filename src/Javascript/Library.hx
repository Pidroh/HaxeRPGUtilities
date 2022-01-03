import js.Syntax;

class JSLibrary{
    
    public static function TryJavascript(){
        Syntax.code("alert({0})", "Whateverrrr");
        
    }
    public static function OpenURL(url){
        Syntax.code("window.location = {0};", url);
        
    }
}