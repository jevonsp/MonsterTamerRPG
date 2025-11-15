class_name PoisonStatus extends StatusEffect

func _init() -> void:
	name = "POISON"
	duration = -1
	
func apply_on_turn_end(monster: Monster) -> void:
	var damage = int(max(1, monster.max_hitpoints / 8.0))
	DialogueManager.show_dialogue("%s is hurt by poison!" % monster.name)
	await DialogueManager.dialogue_closed
	await monster.take_damage(damage)
