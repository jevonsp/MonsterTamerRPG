@abstract
class_name StatusComponent extends Resource

@export_enum("TURN_START", "TURN_END", "STAT_MOD", "CAN_ACT") var trigger: String = "TURN_END"
@export_range(0.0, 1.0) var trigger_chance: float = 1.0

func apply(_monster: Monster, _context: Dictionary) -> bool:
	return true
	
func can_apply(_monster: Monster, _context: Dictionary) -> bool:
	return true
	
func modify_stat(_stat: String, base_value: float, _context: Dictionary) -> float:
	return base_value
	
func can_act(_monster: Monster, _context: Dictionary) -> bool:
	return true
