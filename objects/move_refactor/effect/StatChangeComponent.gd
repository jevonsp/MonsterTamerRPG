class_name StatChangeComponent extends EffectComponent

@export_enum("speed", "attack", "defense", "special_attack", "special_defense", "accuracy", "evasion") var stat
@export_range(-6, 6) var stages: int = 1
@export_enum("MELEE", "RANGED", "TANK") var role_special_effect = ""
@export var targets_self: bool = false
const STAT_NAMES = ["speed", "attack", "defense", "special_attack", "special_defense", "accuracy", "evasion"]

func apply(actor: Monster, target: Monster, _context: Dictionary) -> bool:
	var stat_name = STAT_NAMES[stat]
	var actual_target = target if not targets_self else actor
	
	if not role_special_effect == "":
		if actual_target.role == role_special_effect:
			actual_target.stat_stages[stat_name] -= 2
			
			DialogueManager.show_dialogue("%s had their %s lowered by %s stage(s). 
			Extra effective due to the enemy role!" % [actual_target.name, stat_name, stages])
			await DialogueManager.dialogue_closed
			
			return true
	
	actual_target.stat_stages[stat_name] -= 1
	
	DialogueManager.show_dialogue("%s had their %s lowered by %s stage(s)" % [target.name, stat_name, stages])
	await DialogueManager.dialogue_closed
	return true
