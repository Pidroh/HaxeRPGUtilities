import hscript.Interp;
import hscript.Expr;
import haxe.Json;
import StoryModel;
import StoryData;

class StoryControlLogic {
	public static function Init(jsonStory:String, view:View, runtime:StoryRuntimeData) {
		var cutscenes = Json.parse(jsonStory);
		runtime.cutscenes = cutscenes;
		view.AddButton("cutscenestart", "", (e)->{
			
		});

		var parser = new hscript.Parser();
		for (i in 0...cutscenes.length) {
			if (runtime.persistence.progressionData.exists(cutscenes[i].title) == false) {
				runtime.persistence.progressionData.set(cutscenes[i].title, {
					index: 0,
					timesCompleted: 0,
					visible: false,
					visibleSeen: false
				});
			}
			var vs = cutscenes[i].visibilityScript;
			trace(vs);
			if (vs != null) {
				var script:Expr = parser.parseString(vs);

				runtime.visibilityConditionScripts.push(script);
			} else {
				runtime.visibilityConditionScripts.push(null);
			}
		}
		view.storyMainAction = (actionId, argument) -> {
			if (actionId == View.storyAction_Start) {
				StoryLogic.StartStory(cutscenes[argument].title, runtime);
				view.StartStory();
			}

			if (actionId == View.storyAction_AdvanceMessage) {
				StoryLogic.MessageAdvance(runtime);
			}

			if (view.storyDialogActive && runtime.cutscene == null) {
				view.HideStory();
			}
		}
	}

	// write this possibly stateless, process input inside the function too if possible?
	// add all necessary arguments
	public static function Update(update:Float, runtime:StoryRuntimeData, view:View, executer:Interp) {
		view.StoryButtonAmount(runtime.cutscenes.length);
		var amountVisible = 0;
		var amountVisibleRecognized = 0;
		for (i in 0...runtime.cutscenes.length) {
			var prog = runtime.persistence.progressionData[runtime.cutscenes[i].title];
			if(prog.visible){
				amountVisible++;
				if(prog.visibleSeen)
					amountVisibleRecognized++;
				var completed = false;
			
				// if (prog != null) {
				{
					completed = runtime.persistence.progressionData[runtime.cutscenes[i].title].timesCompleted > 0;
				}
				view.StoryButtonFeed(i, runtime.cutscenes[i].title, completed);
			} else{
				view.StoryButtonHide(i);
			}
		}
		view.SetTabNotification(amountVisible > amountVisibleRecognized, view.storyTab);
		var cutscene = runtime.cutscene;
		if (cutscene != null) {
			var m = cutscene.messages[runtime.currentStoryProgression.index];
			view.LatestMessageUpdate(m.body, m.speaker, runtime.currentStoryProgression.index);
		}

		for (i in 0...runtime.cutscenes.length) {}
		StoryLogic.Update(runtime);
		StoryLogic.VisibilityUpdate(view.IsTabSelected(view.storyTab.component), runtime, executer);
	}
}
