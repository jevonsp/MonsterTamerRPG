class_name StatusApplicationComponent extends EffectComponent

@export var status_effect: GenericStatusContainer
@export var is_primary: bool = true
@export_subgroup("Text")
@export_multiline var message: String = "{target} was afflicted with {name}."

func can_apply(_actor: Monster, target: Monster, _context: Dictionary) -> bool:
	if is_primary:
		if target.status != null:
			DialogueManager.show_dialogue(
				"%s is already afflicted with %s!" % [target.name, target.status.name])
			await DialogueManager.dialogue_closed
			return false
		
		return true
	else:
		for existing in target.stacking_statuses:
			if existing.get_script() == status_effect.get_script():
				DialogueManager.show_dialogue(
					"%s is already affected by %s!" % [target.name, status_effect.name])
				await DialogueManager.dialogue_closed
				return false
		return true

func apply(_actor: Monster, target: Monster, context: Dictionary) -> bool:
	var move = context.get("move")
	var move_name = move.name if move else "The move"
	
	var status_message: String = message.format({
		"move_name": move_name,
		"target": target.name,
		"name": status_effect.name
	})
	
	for component in status_effect.components:
		if component is DurationComponent:
			component.reset_for_new_application()
	
	if is_primary:
		target.status = status_effect.duplicate()
		print("target.status: ", target.status)
	else:
		target.stacking_statuses.append(status_effect.duplicate())
		print("target.stacking_statuses: ", target.stacking_statuses)
	
	DialogueManager.show_dialogue(status_message)
	await DialogueManager.dialogue_closed
	
	return true
