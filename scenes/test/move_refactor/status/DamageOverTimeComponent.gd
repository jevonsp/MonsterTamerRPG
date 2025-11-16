class_name DamageOverTimeComponent extends StatusComponent

@export_range(0.0, 1.0) var percentage: float = 0.0625 # 1/16th
@export var is_healing: bool = false


func apply(monster: Monster, context: Dictionary) -> bool:
	var amount = monster.max_hitpoints * percentage
	
	if is_healing:
		await monster.heal(amount)
		DialogueManager.show_dialogue("%s is healed by their %s" % [monster.name, context.get("name", "")])
		await DialogueManager.dialogue_closed
	else:
		await monster.take_damage(amount)
		DialogueManager.show_dialogue("%s is hurt by their %s" % [monster.name, context.get("name", "")])
		await DialogueManager.dialogue_closed
	
	return true
