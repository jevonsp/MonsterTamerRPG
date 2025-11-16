class_name StatModifierComponent extends StatusComponent

@export_enum("speed", "attack", "defense", "special_attack", "special_defense") var stat: String
@export_range(0.0, 1.0) var multiplier: float = 1.0

func modify_stat(stat_name: String, base_value: float, _context: Dictionary) -> float:
	print("base_value: %s, multi: %s" % [base_value, multiplier])
	print("stat end value: ",  base_value * multiplier)
	if stat == stat_name:
		return base_value * multiplier
	return base_value
