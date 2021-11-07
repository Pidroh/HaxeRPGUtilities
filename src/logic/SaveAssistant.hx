import haxe.Json;

class SaveAssistant{
    public static function GetPersistenceMaster(jsonData) : PersistenceMaster{
        if (jsonData != null && jsonData != "") {
			var parsed = Json.parse(jsonData);
			var persistenceMaster:PersistenceMaster = parsed;
			
			// LEGACY DATA SUPPORT
			// this means it is the old type of data
			if (persistenceMaster.worldVersion >= 602 == false) {
				persistenceMaster.jsonGameplay = jsonData;
			}
            return persistenceMaster;
		} else{
            return {worldVersion: -1, jsonStory: null, jsonGameplay: null};
        }
        
    }
}

typedef PersistenceMaster = {
	var worldVersion:Int;
	var jsonGameplay:String;
	var jsonStory:String;
}
