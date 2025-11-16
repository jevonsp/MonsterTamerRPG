class_name HealComponent extends EffectComponent

@export var heal_flat_amount: int = 20
@export var is_percentage: bool = false
@export_range(0.0, 1.0) var heal_percentage_amount: float = 0.0
@export var heals_enemy: bool = false

var message: String = "{target} healed for {amount}"

func apply(actor: Monster, target: Monster, _context: Dictionary) -> bool:
	var heal_amount = heal_flat_amount
	var actual_target = actor if not heals_enemy else target
	
	if is_percentage and heal_percentage_amount > 0:
		heal_amount = int(actual_target.max_hitpoints * heal_percentage_amount)
	
	await actual_target.heal(heal_amount)
	
	var heal_message: String = message.format({"target": actual_target.name, "amount": str(heal_amount)})
	DialogueManager.show_dialogue(heal_message)
	await DialogueManager.dialogue_closed
	
	return true
