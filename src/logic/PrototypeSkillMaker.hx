import RPGData;

class PrototypeSkillMaker {
	public var skills = new Array<Skill>();

	public function new() {}

	public function AddSkill(id:String, mpCost:Int) {}

	public function init() {
		// AddSkill("Regen", 25);

		skills.push({
			id: "Regen",
			profession: "Priest",
			word: "Nature",
			effects: [
				{
					target: SELF,
					effectExecution: (bm, level, actor, array) -> {
						var strength = level * 3;
						bm.AddBuff({
							uniqueId: "regen",
							addStats: ["Regen" => strength],
							mulStats: null,
							strength: strength,
							duration: 8
						}, actor);
					}
				}
			],
			mpCost: 20
		});
/*		skills.push({
			id: "Fire Edge",
			profession: "Enchanter",
			word: "Flame",
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
		*/
		skills.push({
			id: "Light Slash",
			profession: "Warrior",
			word: "Red",
			effects: [
				{
					target: ENEMY,
					effectExecution: (bm, level, actor, array) -> {
						var strength = level * 5;
						bm.AttackExecute(actor, array[0], 50, 5+level, 100);
					}
				}
			],
			mpCost: 5
		});
		skills.push({
			id: "Slash",
			profession: "Warrior",
			word: "Red",
			effects: [
				{
					target: ENEMY,
					effectExecution: (bm, level, actor, array) -> {
						var strength = level * 10;
						bm.AttackExecute(actor, array[0], 90+strength, 10, 100);
					}
				}
			],
			mpCost: 15
		});
		skills.push({
			id: "Heavy Slash",
			profession: "Warrior",
			word: "Red",
			effects: [
				{
					target: ENEMY,
					effectExecution: (bm, level, actor, array) -> {
						var strength = level * 30;
						bm.AttackExecute(actor, array[0], 100+strength, 15, 100);
					}
				}
			],
			mpCost: 40
		});
		skills.push({
			id: "Cure",
			profession: "Mage",
			word: "White",
			effects: [
				{
					target: SELF,
					effectExecution: (bm, level, actor, array) -> {
						//15, 50, 105, 180
						var bonus = 5 + level * 10;
						var strength = level * bonus;
						bm.Heal(array[0], 10, bonus);
					}
				}
			],
			mpCost: 15
		});
		skills.push({
			id: "Haste",
			profession: "Wizard",
			word: "Time",
			effects: [
				{
					target: SELF,
					effectExecution: (bm, level, actor, array) -> {
						var bonus = 20;
						var multiplier = 90+level *10;
                        bm.AddBuff({
							uniqueId: "haste",
							addStats: ["Speed" => bonus],
							mulStats: ["Speed" => multiplier],
							strength: level,
							duration: 8
						}, actor);						
					}
				}
			],
			mpCost: 45
		});
		skills.push({
			id: "Protect",
			profession: "Defender",
			word: "Defense",
			effects: [
				{
					target: SELF,
					effectExecution: (bm, level, actor, array) -> {
						var bonus = level*5;
						var multiplier = 110;
                        bm.AddBuff({
							uniqueId: "protect",
							addStats: ["Defense" => bonus],
							mulStats: ["Defense" => multiplier],
							strength: level,
							duration: 8
						}, actor);						
					}
				}
			],
			mpCost: 25
		});
		skills.push({
			id: "Sharpen",
			profession: "Smith",
			word: "Sharpness",
			effects: [
				{
					target: SELF,
					effectExecution: (bm, level, actor, array) -> {
						var bonus = 100;
						var multiplier = 100+5*level;
                        bm.AddBuff({
							uniqueId: "pierce",
							addStats: ["Pierce" => bonus],
							mulStats: ["Attack" => multiplier],
							strength: level,
							duration: 9
						}, actor);						
					}
				}
			],
			mpCost: 20
		});
		skills.push({
			id: "Sharpen",
			profession: "Smith",
			word: "Sharpness",
			effects: [
				{
					target: SELF,
					effectExecution: (bm, level, actor, array) -> {
						var bonus = 100;
						var multiplier = 100+5*level;
                        bm.AddBuff({
							uniqueId: "pierce",
							addStats: ["Pierce" => bonus],
							mulStats: ["Attack" => multiplier],
							strength: level,
							duration: 9
						}, actor);						
					}
				}
			],
			mpCost: 20
		});

		skills.push({
			id: "Armor Break",
			profession: "Breaker",
			word: "Destruction",
			effects: [
				{
					target: SELF,
					effectExecution: (bm, level, actor, array) -> {
						
                        bm.AddBuff({
							uniqueId: "Armor Break",
							addStats: ["Defense" => -level*10],
							mulStats: ["Defense" => 50],
							strength: level,
							duration: 5,
							debuff: true
						}, actor);				
					}
				}
			],
			mpCost: 10
		});

		skills.push({
			id: "Attack Break",
			profession: "Breaker",
			word: "Destruction",
			effects: [
				{
					target: SELF,
					effectExecution: (bm, level, actor, array) -> {
						
                        bm.AddBuff({
							uniqueId: "Attack Break",
							addStats: ["Attack" => -level*10],
							mulStats: ["Attack" => 50],
							strength: level,
							duration: 5,
							debuff: true
						}, actor);				
					}
				}
			],
			mpCost: 10
		});
	}
}
