import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import StoryData;

class Transpiler {
	static function main() {
		trace("Transpiler begin");
		var directoryPath = "C:\\Users\\user\\gamedev\\_haxe\\HaxeRPGUtilities\\assets";
		var json = File.getContent("C:\\Users\\user\\gamedev\\_haxe\\HaxeRPGUtilities.wiki\\yarn.json");
		var master:Array<Dynamic> = Json.parse(json);
		//trace(json);
		//Sys.print(json);
		var masterOutput:Array<Cutscene> = [];
		for (a in master) {
			var title:String = a.title;
			var tags = a.tags;
			var body:String = a.body;
			var lines = body.split('\n');
			var cutscene:Cutscene = {
				messages: [],
				title: title,
				visibilityScript: null,
				actionLabel: null
			};
			masterOutput.push(cutscene);

			for (l in lines) {
				var message:Message;
				var script = null;
				if (StringTools.contains(l, "<H")) {
					trace("Script found");
					
					var haxeScriptStart = l.indexOf("<H");
					script = l.substring(haxeScriptStart + 2, l.indexOf("H>"));
					trace(script);

					if (StringTools.contains(script, "CONDITION")) {
						cutscene.visibilityScript = StringTools.replace(script, "CONDITION", "");
						script = null;
						continue;
					}
					if (script.indexOf("BUTTONLABEL") != -1) {
						cutscene.actionLabel = StringTools.replace(script, "BUTTONLABEL", "");
						trace("BUTTON LABEL FOUND");
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
				message = {body: messageB, speaker: speaker, script: script};
				cutscene.messages.push(message);
			}
		}

		File.saveContent(directoryPath + "\\story.json", Json.stringify(masterOutput));
		trace(Json.stringify(masterOutput));
	}
}
