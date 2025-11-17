class_name SwitchPreventionComponent extends StatusComponent

@export_multiline var prevention_message: String = "{monster} is trapped and cannot be switched out!"

func can_switch(monster: Monster, _context: Dictionary) -> bool:
	if prevention_message:
		var message = prevention_message.format({"monster": monster.name})
		DialogueManager.show_dialogue(message)
		await DialogueManager.dialogue_closed
	return false
