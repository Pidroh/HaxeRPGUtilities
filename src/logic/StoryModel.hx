import StoryData;

class StoryLogic{
    public static function Update(runtime : StoryRuntimeData){
        runtime.toShow = runtime.cutscene.messages[runtime.currentStoryProgression.index];
    }

    	// find story progression and reset it
	public static function StartStory(sceneId:String, runtime : StoryRuntimeData) {
		var progressionData = runtime.persistence.progressionData;
		if (progressionData.exists(sceneId) == false) {
			progressionData.set(sceneId, {index: 0, visible: true, timesCompleted: 0});
		}
		progressionData[sceneId].index = 0;
		runtime.toShow = null;

        runtime.currentStoryProgression = progressionData[sceneId];

        for(a in runtime.cutscenes){
            if(a.title == sceneId){
                runtime.currentCutsceneIndex = runtime.cutscenes.indexOf(a);
                break;
            }
        }
	}

    public static function MessageAdvance(runtime : StoryRuntimeData){
        runtime.currentStoryProgression.index++;
        if(runtime.currentStoryProgression.index >= runtime.cutscene.messages.length){
            runtime.currentStoryProgression = null;
            runtime.cutscene = null;
        }
    }

    
}

typedef StoryPersistence = {
	var progressionData:Map<String, StoryProgress>;
    var currentStoryId : String;
}

typedef StoryProgress = {
    var index : Int;
    var timesCompleted : Int;
    var visible : Bool;
}

typedef StoryRuntimeData = {
    var currentStoryProgression: StoryProgress;
	var cutscenes :Array<Cutscene>;
    var cutscene : Cutscene;
	var persistence: StoryPersistence;
	var currentCutsceneIndex : Int;
	var toShow : Message;
    
}


