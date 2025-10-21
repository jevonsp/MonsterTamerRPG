class_name FreezeStatus extends StatusEffect

func _init() -> void:
	name = "FREEZE"
	duration = randi_range(1,3)
	turns_remaining = duration
	
func can_act(monster: Monster) -> bool:
	if randf() < 0.2:
		DialogueManager.show_dialogue("%s thawed out!" % monster.name)
		await DialogueManager.dialogue_closed
		monster.status = null  # Remove freeze
		return true
	DialogueManager.show_dialogue("%s is frozen solid!" % monster.name)
	await DialogueManager.dialogue_closed
	return false
