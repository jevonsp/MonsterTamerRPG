class_name BurnStatus extends StatusEffect

func _init() -> void:
	name = "BURN"
	duration = -1

func apply_on_turn_end(monster: Monster) -> void:
	var damage = int(max(1, monster.max_hitpoints / 16.0))
	DialogueManager.show_dialogue("%s is hurt by its burn!" % monster.name)
	await DialogueManager.dialogue_closed
	await monster.take_damage(damage)
	
func modify_stat(stat: String, base_value: int) -> int:
	if stat == "attack":
		return int(base_value * 0.5)
	return base_value
