class_name StatChangeComponent extends EffectComponent

@export_enum("speed", "attack", "defense", "special_attack", "special_defense", "accuracy", "evasion") var stat
@export_range(-6, 6) var stages: int = 1
@export_enum("MELEE", "RANGED", "TANK") var role_special_effect = ""

const STAT_NAMES = ["speed", "attack", "defense", "special_attack", "special_defense", "accuracy", "evasion"]

func apply(_actor: Monster, target: Monster, _context: Dictionary) -> bool:
	var stat_name = STAT_NAMES[stat]
	
	if not role_special_effect == "":
		if target.role == role_special_effect:
			target.stat_stages[stat_name] -= 2
			
			DialogueManager.show_dialogue("%s had their %s lowered by %s stage(s). 
			Extra effective due to the enemy role!" % [target.name, stat_name, stages])
			await DialogueManager.dialogue_closed
			
			return true
	
	target.stat_stages[stat_name] -= 1
	
	DialogueManager.show_dialogue("%s had their %s lowered by %s stage(s)" % [target.name, stat_name, stages])
	await DialogueManager.dialogue_closed
	return true
