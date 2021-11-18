import RPGData;

class PrototypeSkillMaker {
	public var skills = new Array<Skill>();

	public function new() {}

	public function init() {
		skills.push({
			id: "Regen",
			effects: [
				{
					target: SELF,
					effectExecution: (level, actor, array) -> {
						var strength = level * 5;
						actor.buffs.push({
							uniqueId: "regen",
							addStats: ["Regen" => strength],
							mulStats: null,
							strength: strength,
							duration: 5
						});
					}
				}
			]
		});
		skills.push({
			id: "Fire Edge",
			effects: [
				{
					target: SELF,
					effectExecution: (level, actor, array) -> {
						var strength = level * 5;
						actor.buffs.push({
							uniqueId: "enchant-fire",
							addStats: ["enchant-fire" => strength],
							mulStats: null,
							strength: strength,
							duration: 5
						});
					}
				}
			]
		});
	}
}
