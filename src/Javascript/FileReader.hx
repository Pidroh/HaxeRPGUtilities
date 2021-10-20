import haxe.crypto.Base64;
import js.Syntax;
import js.html.File;
import js.html.FileReader;

class FileUtilities{
    public static function GetFetchTextContent() : String{
        var fileText = Syntax.code('fetchTextContent');

        //resets variable after reading
        if(fileText != '') Syntax.code('fetchTextContent = "";');
        return fileText;
    }
    public static function ReadFile(file, callback:String->Void) {

        //Syntax.code('fetch({0}).then(response => response.text()).then(data => fetchTextContent = data)', file);

        //var freader = FileReader();
        
        var fReader = new FileReader();
        fReader.readAsDataURL(file);
        fReader.onloadend = function(event){
            trace(event.target.result);
            trace(event.target.value);
            var content = event.target.result;
            //var savedata = StringTools.urlDecode(event.target.result);
            //["data:application/json;base64,".length,]
            var string : String = event.target.result;
            if(StringTools.contains(string,"data:application/json;base64,"))
            {
                var savedata = Base64.decode(string.substr("data:application/json;base64,".length));

                callback(savedata.toString());
            }
            
            
            
            
        }
        
    }
}
