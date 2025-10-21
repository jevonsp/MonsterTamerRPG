class_name SleepStatus extends StatusEffect

func _init() -> void:
	name = "SLEEP"
	duration = randi_range(1, 3)
	turns_remaining = duration
	
func can_act(monster: Monster) -> bool:
	DialogueManager.show_dialogue("%s is fast asleep!" % monster.name)
	await DialogueManager.dialogue_closed
	return false
