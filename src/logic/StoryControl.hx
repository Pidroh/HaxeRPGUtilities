import haxe.Json;
import StoryModel;
import StoryData;

class StoryControlLogic {
	public static function Init(jsonStory:String, view:View, runtime:StoryRuntimeData) {
		var cutscenes = Json.parse(jsonStory);
		runtime.cutscenes = cutscenes;
		view.storyMainAction = (actionId, argument) -> {
			if (actionId == View.storyAction_Start) {
				StoryLogic.StartStory(cutscenes[actionId].title, runtime);
			}
			if (actionId == View.storyAction_AdvanceMessage) {
				StoryLogic.MessageAdvance(runtime);
			}
		}
	}

	// write this possibly stateless, process input inside the function too if possible?
	// add all necessary arguments
	public static function Update(update:Float, runtime:StoryRuntimeData, view:View) {
		//view.StoryButtonAmount(runtime.cutscenes.length);
		for (i in 0...runtime.cutscenes.length){
			view.StoryButtonFeed(i, 
				runtime.cutscenes[i].title, 
				runtime.persistence.progressionData[runtime.cutscenes[i].title].timesCompleted > 0);
		}
			var cutscene = runtime.cutscene;
		if (cutscene != null) {
			var m = cutscene.messages[runtime.currentStoryProgression.index];
			view.LatestMessageUpdate(m.speaker, m.body, runtime.currentStoryProgression.index);
		}

		for (i in 0...runtime.cutscenes.length) {}
		StoryLogic.Update(runtime);
	}
}
