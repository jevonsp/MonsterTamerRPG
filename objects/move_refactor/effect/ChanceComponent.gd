class_name ChanceComponent extends EffectComponent

@export_range(0.0, 1.0) var success_chance: float = 1.0
var should_skip_next: bool = false

func can_apply(_actor: Monster, _target: Monster, _context: Dictionary) -> bool:
	var random = randf()
	print("random: ", random, " success_chance: ", success_chance)
	var result = random <= success_chance
	print("result: ", result)
	
	should_skip_next = not result
	
	return true
