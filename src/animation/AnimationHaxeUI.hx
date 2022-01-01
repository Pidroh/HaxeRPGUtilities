import haxe.ui.core.Component;
import AnimationP;

class AnimationComponent {
	public function new() {}

	var animManager = new AnimationManager();
	var animationComp = new Map<Component, Array<AnimationExecutionData>>();

	public function update(delta:Float) {
		var timeCen = Std.int(delta * 100);
		if (delta > 0 && timeCen == 0)
			timeCen = 1;
		for (key => value in animationComp) {
			for (i in 0...value.length) {
				var anim = value[i];
				anim.timeCenti += timeCen;
				var frames = anim.animation.frames;
				var timeC = anim.timeCenti;
				var frameIndex = -1;
				for (j in 0...frames.length) {
					if (timeC <= frames[j].centiseconds) {
						frameIndex = j;
						break;
					} else {
						timeC -= frames[j].centiseconds;
					}
				}

				// interpolates between previous and current frame
				if (frameIndex >= 1) {
					var frame = frames[frameIndex];
					var oldFrame = frames[frameIndex - 1];
					var lengthFrame = frame.centiseconds - oldFrame.centiseconds;
					var prog = timeC / lengthFrame;
					if (oldFrame.position != null) {
						var posF = frame.position;
						var pos = oldFrame.position;
						key.left = interpolate(pos.x, posF.x, prog);
						key.top = interpolate(pos.y, posF.y, prog);
					}
				}
			}
		}
	}

	public function interpolate(x0, x1, inter:Float):Int {
		var d = x1 - x0;
		return Std.int(d * inter + x0);
	}

	public function playAnimation(comp:Component, anim:String) {
		var anims = animationComp[comp];
		if (anims == null) {
			anims = new Array<AnimationExecutionData>();
			animationComp[comp] = anims;
		}
		anims.push(new AnimationExecutionData(animManager.animations[anim]));
	}
}
