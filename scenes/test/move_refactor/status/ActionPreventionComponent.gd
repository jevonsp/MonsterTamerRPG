class_name ActionPreventionComponent extends StatusComponent

@export_enum("ALWAYS", "CHANCE") var prevention_type: String = "CHANCE"
@export_range(0.0, 1.0) var prevention_chance: float = 0.25
@export_multiline var prevention_message: String = ""

func can_act(monster: Monster, _context: Dictionary) -> bool:
	print("DEBUG: ActionPreventionComponent - checking can_act for ", monster.name)
	var can_act_result = true
	
	match prevention_type:
		"ALWAYS": 
			print("DEBUG: ActionPreventionComponent - ALWAYS prevention")
			can_act_result = false
		"CHANCE":
			var roll = randf()
			print("DEBUG: ActionPreventionComponent - CHANCE prevention, roll: ", roll, " vs chance: ", prevention_chance)
			can_act_result = roll > prevention_chance
	
	print("DEBUG: ActionPreventionComponent - can_act_result: ", can_act_result)
	
	if not can_act_result and prevention_message:
		var message = prevention_message.format({"monster": monster.name})
		print("DEBUG: ActionPreventionComponent - showing message: ", message)
		DialogueManager.show_dialogue(message)
		await DialogueManager.dialogue_closed
	
	return can_act_result
