import hscript.Interp;
import hscript.Expr;
import StoryData;

class StoryLogic {
	public static function Update(runtime:StoryRuntimeData) {
		if (runtime.cutscene != null)
			runtime.toShow = runtime.cutscene.messages[runtime.currentStoryProgression.index];
	}

	public static function VisibilityUpdate(storyButtonsVisible:Bool, runtime:StoryRuntimeData, executer:Interp) {
		for (i in 0...runtime.cutscenes.length) {
			var prog = runtime.persistence.progressionData[runtime.cutscenes[i].title];
			if (prog != null) {
				var visible = prog.visible;
				if (visible == false) {
					var wantVisible = true;
					if (runtime.visibilityConditionScripts[i] != null)
						wantVisible = executer.execute(runtime.visibilityConditionScripts[i]);
					if (wantVisible) {
						prog.visible = true;
					}
				}

				if (storyButtonsVisible) {
					if (prog.visible)
						prog.visibleSeen = true;
				}
			}
		}
	}

	// find story progression and reset it
	public static function StartStory(sceneId:String, runtime:StoryRuntimeData) {
		var progressionData = runtime.persistence.progressionData;
		progressionData[sceneId].index = 0;
		runtime.toShow = null;

		runtime.currentStoryProgression = progressionData[sceneId];

		for (a in runtime.cutscenes) {
			if (a.title == sceneId) {
				runtime.currentCutsceneIndex = runtime.cutscenes.indexOf(a);
				runtime.cutscene = a;
				break;
			}
		}
	}

	public static function MessageAdvance(runtime:StoryRuntimeData) {
		runtime.currentStoryProgression.index++;
		if (runtime.currentStoryProgression.index >= runtime.cutscene.messages.length) {
            runtime.currentStoryProgression.timesCompleted++;
			runtime.currentStoryProgression = null;
			runtime.cutscene = null;
		}
	}
}

typedef StoryPersistence = {
	var progressionData:Map<String, StoryProgress>;
	var currentStoryId:String;
}

typedef StoryProgress = {
	var index:Int; //message index, not cutscene index
	var timesCompleted:Int;
	var visible:Bool;
	var visibleSeen:Bool;
}

typedef StoryRuntimeData = {
	var currentStoryProgression:StoryProgress;
	var cutscenes:Array<Cutscene>;
	var visibilityConditionScripts:Array<Expr>;
	var cutscene:Cutscene;
    var cutsceneStartable:Cutscene;
	var persistence:StoryPersistence;
	var currentCutsceneIndex:Int;
	var toShow:Message;
}
