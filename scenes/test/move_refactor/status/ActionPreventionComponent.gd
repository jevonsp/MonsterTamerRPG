class_name ActionPreventionComponent extends StatusComponent

@export_enum("ALWAYS", "CHANCE") var prevention_type: String = "CHANCE"
@export_range(0.0, 1.0) var prevention_chance: float = 0.25
@export_multiline var prevention_message: String = ""

func can_act(monster: Monster, _context: Dictionary) -> bool:
	var can_act_result = true
	
	match prevention_type:
		"ALWAYS": 
			can_act_result = false
		"CHANCE":
			var roll = randf()
			can_act_result = roll > prevention_chance
	
	if not can_act_result and prevention_message:
		var message = prevention_message.format({"monster": monster.name})
		DialogueManager.show_dialogue(message)
		await DialogueManager.dialogue_closed
	
	return can_act_result
