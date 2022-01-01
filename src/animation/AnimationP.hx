typedef Point = {
	x:Int,
	y:Int
}

typedef AnimFrame = {
	centiseconds:Float,
	?position:Point
}

class Animation {
	public var frames = new Array<AnimFrame>();
    public function new() {}
}

class AnimationManager {
	public function new() {}

	public var animations = new Map<String, Animation>();

    public function feedAnimationInfo(anim:String, frame:Int, centiseconds:Int, frameD:AnimFrame){
        if(animations.exists(anim) == false){
            animations[anim] = new Animation();
        }
        var a = animations[anim];
        a.frames[frame] = frameD;
    }
}
