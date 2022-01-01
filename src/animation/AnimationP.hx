typedef Point = {
	x:Int,
	y:Int
}

typedef AnimFrame = {
	centiseconds:Int,
	?position:Point
}

class Animation {
	public var id:String;
	public var frames = new Array<AnimFrame>();

	public function new(id:String) {
		this.id = id;
	}
}

class AnimationExecutionData{
    public var timeCenti : Int;
    public var animation : Animation;
	public function new(anim){
		animation = anim;
		timeCenti = 0;
	}
}

class AnimationManager {
	public function new() {}

	public var animations = new Map<String, Animation>();

	public function feedAnimationInfo(anim:String, frame:Int, centiseconds:Int, frameD:AnimFrame) {
		if (animations.exists(anim) == false) {
			animations[anim] = new Animation(anim);
		}
		var a = animations[anim];
		a.frames[frame] = frameD;
	}
}
