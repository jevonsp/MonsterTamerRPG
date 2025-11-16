class_name StatusApplicationComponent extends EffectComponent

@export var status_effect: GenericStatusContainer
@export var is_primary: bool = true
var message: String = "{target} was afflicted with {name}"

func apply(_actor: Monster, target: Monster, context: Dictionary) -> bool:
	var move = context.get("move")
	var move_name = move.name if move else "The move"
	
	var status_message: String = message.format({
		"move_name": move_name,
		"target": target.name,
		"name": status_effect.name
	})
	
	# Reset any DurationComponents in the status effect
	for component in status_effect.components:
		if component is DurationComponent:
			component.reset_for_new_application()
	
	if is_primary:
		target.status = status_effect.duplicate()
	else:
		target.stacking_statuses.append(status_effect.duplicate())
	
	DialogueManager.show_dialogue(status_message)
	await DialogueManager.dialogue_closed
	
	return true
