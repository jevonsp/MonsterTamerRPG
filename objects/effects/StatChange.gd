class_name StatChange extends BattleEffect

@export_range(0.0, 1.0) var change_chance: float = 0.3
@export_enum("speed", "attack", "defense", "special_attack", "special_defense", "accuracy", "evasion") var stat
@export_range(-6, 6) var stages: int = 1
@export_enum("MELEE", "RANGED", "TANK") var role_special_effect = ""

const STAT_NAMES = ["speed", "attack", "defense", "special_attack", "special_defense", "accuracy", "evasion"]

var name = "STAT"

func apply(actor_ref: Monster, target_ref: Monster, data_ref) -> void:
	super(actor_ref, target_ref, data_ref)
	animation_type = "TARGET"
	
	if randf() > change_chance:
		return
		
	var stat_name = STAT_NAMES[stat]
	
	if not role_special_effect == "":
		if target.role == role_special_effect:
			target.stat_stages[stat_name] -= 2
			
			DialogueManager.show_dialogue("%s had their %s lowered by %s stage(s). 
			Extra effective due to the enemy role!" % [target.name, stat_name, stages])
			await DialogueManager.dialogue_closed
			
			return
	
	target.stat_stages[stat_name] -= 1
	
	DialogueManager.show_dialogue("%s had their %s lowered by %s stage(s)" % [target.name, stat_name, stages])
	await DialogueManager.dialogue_closed
