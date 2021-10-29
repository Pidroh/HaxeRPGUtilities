import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import StoryData;

class Transpiler {
	static function main() {
		var directoryPath = "C:\\Users\\user\\gamedev\\_haxe\\HaxeRPGUtilities\\assets";
		var json = File.getContent("C:\\Users\\user\\gamedev\\_haxe\\HaxeRPGUtilities.wiki\\yarn.json");
		var master:Array<Dynamic> = Json.parse(json);
		var masterOutput:Array<Cutscene> = [];
		for (a in master) {
			var title:String = a.title;
			var tags = a.tags;
			var body:String = a.body;
			var lines = body.split('\n');
			var cutscene:Cutscene = {messages: [], title: title, visibilityScript: null};
			masterOutput.push(cutscene);

			for (l in lines) {
				var message:Message;
				if (StringTools.contains(l, "<H")) {
					var haxeScriptStart = l.indexOf("<H");
					var script = l.substring(haxeScriptStart + 2, l.indexOf("H>"));
					if (StringTools.contains(script, "CONDITION")) {
            cutscene.visibilityScript = StringTools.replace(script, "CONDITION", "");
            continue;
          }
					l = l.split(l.substring(haxeScriptStart, l.indexOf("H>") - 2))[0];
				}

				var parts = l.split(':');
				var speaker = null;
				var messageB = l;
				if (parts.length > 1) {
					speaker = parts[0];
					messageB = parts[1];
				}
				message = {body: messageB, speaker: speaker};
				cutscene.messages.push(message);
			}
		}

		File.saveContent(directoryPath + "\\story.json", Json.stringify(masterOutput));
		trace(Json.stringify(masterOutput));
	}
}
