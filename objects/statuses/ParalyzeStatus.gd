class_name ParalyzeStatus extends StatusEffect

func _init() -> void:
	name = "PARALYZE"
	duration = -1
	
func can_act(monster: Monster) -> bool:
	if randf() < 0.25:
		DialogueManager.show_dialogue("%s was paralyzed and couldn't act!" % monster.name)
		await DialogueManager.dialogue_closed
		return false
	return true
	
func modify_stat(stat: String, base_value: int) -> int:
	if stat == "speed":
		return int(base_value * 0.5)
	return base_value
