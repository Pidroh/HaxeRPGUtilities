import hscript.Interp;
import hscript.Expr;
import haxe.Json;
import StoryModel;
import StoryData;

class StoryControlLogic {
	public static function Init(jsonStory:String, view:View, runtime:StoryRuntimeData) {
		var cutscenes = Json.parse(jsonStory);
		runtime.cutscenes = cutscenes;
		view.AddButton("cutscenestart", "", (e) -> {
			if (runtime.cutsceneStartable != null && runtime.cutscene == null) {
				StoryLogic.StartStory(runtime.cutsceneStartable.title, runtime);
				view.StartStory();
			}
		}, null, 0);

		var parser = new hscript.Parser();
		for (i in 0...cutscenes.length) {
			if (runtime.persistence.progressionData.exists(cutscenes[i].title) == false) {
				runtime.persistence.progressionData.set(cutscenes[i].title, {
					index: 0,
					timesCompleted: 0,
					visible: false,
					visibleSeen: false,
					wantToWatch: false
				});
			}
			var vs = cutscenes[i].visibilityScript;
			// trace(vs);
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

			if (actionId == View.storyAction_Continue) {
				StoryLogic.StartStory(cutscenes[argument].title, runtime, true);
				view.StartStory();
			}

			if (actionId == View.storyAction_AdvanceMessage) {
				StoryLogic.MessageAdvance(runtime);
			}

			if (actionId == View.storyAction_WatchLater) {
				StoryLogic.WatchLater(runtime);
			}

			if (actionId == View.storyAction_WatchLaterClose) {
				StoryLogic.WatchLater(runtime);
			}

			if (actionId == View.storyAction_SkipStory) {
				StoryLogic.SkipStory(runtime);
			}

			if (view.storyDialogActive && runtime.cutscene == null && actionId != View.storyAction_WatchLaterClose) {
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
		runtime.cutsceneStartable = null;
		for (i in 0...runtime.cutscenes.length) {
			var prog = runtime.persistence.progressionData[runtime.cutscenes[i].title];
			if (runtime.cutsceneStartable == null && prog.timesCompleted == 0 && prog.visible == true) {
				runtime.cutsceneStartable = runtime.cutscenes[i];
			}
			if (prog.visible && prog.timesCompleted > 0) {
				amountVisible++;
				if (prog.visibleSeen)
					amountVisibleRecognized++;
				var completed = false;

				// if (prog != null) {
				completed = prog.timesCompleted > 0;
				var resumable = prog.index > 0;
				var newLabel = prog.wantToWatch;
				var newLabelText = "NEW";
				if(prog.timesCompleted > 1)
					newLabelText = "Watch later";
				view.StoryButtonFeed(i, runtime.cutscenes[i].title, completed,resumable, newLabel, newLabelText);
			} else {
				view.StoryButtonHide(i);
			}
		}
		view.ButtonEnabled("cutscenestart", runtime.cutsceneStartable != null);
		if (runtime.cutsceneStartable != null) {
			view.ButtonLabel("cutscenestart", runtime.cutsceneStartable.actionLabel + "\n<i>(Story)</i>");
		} else {
			// view.ButtonLabel("cutscenestart", "\n<i>(Story)</i>");
		}

		view.SetTabNotification(amountVisible > amountVisibleRecognized, view.storyTab);
		var cutscene = runtime.cutscene;

		if(view.storyDialogUtilityFlag){
			view.storyDialogUtilityFlag = false;
			view.storyDialog.scroll.vscrollPos = 9999;
		}
		
		if (cutscene != null) {
			while(view.amountOfStoryMessagesShown <= runtime.currentStoryProgression.index){
				var m = cutscene.messages[view.amountOfStoryMessagesShown];
				view.LatestMessageUpdate(m.body, m.speaker,runtime.speakerToImage[m.speaker.toLowerCase()], view.amountOfStoryMessagesShown);
				view.storyDialogUtilityFlag = true;
			}
		}

		for (i in 0...runtime.cutscenes.length) {}
		StoryLogic.Update(runtime);
		StoryLogic.VisibilityUpdate(view.IsTabSelected(view.storyTab.component), runtime, executer);
	}

	public static function ReadJsonPersistentData(json:String) : StoryPersistence{
		var persistence : StoryPersistence = Json.parse(json);
		return persistence;
	}

	public static function GetJsonPersistentData(runtime:StoryRuntimeData) : String{
		return Json.stringify(runtime.persistence);
	}
}
