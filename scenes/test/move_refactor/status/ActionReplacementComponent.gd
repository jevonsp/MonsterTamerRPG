class_name ActionReplacementComponent extends StatusComponent

@export_range(0.0, 1.0) var replacement_chance: float = 1.0
@export var replacement_effects: Array[EffectComponent] = []
@export_multiline var message: String = ""

func can_act(monster: Monster, context: Dictionary) -> bool:
	if randf() > replacement_chance:
		return true
	
	if message:
		DialogueManager.show_dialogue(message.format({"monster": monster.name}))
		await DialogueManager.dialogue_closed
		
	for effect in replacement_effects:
		if effect.can_apply(monster, monster, context):
			@warning_ignore("redundant_await")
			await effect.apply(monster, monster, context)
	
	return false
	
func apply(_monster: Monster, _context: Dictionary) -> bool:
	return true
