import RPGData;

class PrototypeSkillMaker {
	public var skills = new Array<Skill>();

	public function new() {}

	public function AddSkill(id:String, mpCost:Int) {}

	public function init() {
		// AddSkill("Regen", 25);

		skills.push({
			id: "Regen",
			effects: [
				{
					target: SELF,
					effectExecution: (bm, level, actor, array) -> {
						var strength = level * 5;
						bm.AddBuff({
							uniqueId: "regen",
							addStats: ["Regen" => strength],
							mulStats: null,
							strength: strength,
							duration: 5
						}, actor);
					}
				}
			],
			mpCost: 20
		});
		skills.push({
			id: "Fire Edge",
			effects: [
				{
					target: SELF,
					effectExecution: (bm, level, actor, array) -> {
						var strength = level * 5;
                        bm.AddBuff({
							uniqueId: "enchant-fire",
							addStats: ["enchant-fire" => strength],
							mulStats: null,
							strength: strength,
							duration: 5
						}, actor);
						
					}
				}
			],
			mpCost: 20
		});
	}
}
