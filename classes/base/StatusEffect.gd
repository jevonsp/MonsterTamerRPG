@abstract
class_name StatusEffect extends Resource

@export var name: String = ""
@export var duration: int = -1

var turns_remaining = 0

func apply_on_turn_start(_monster: Monster) -> void:
	pass
	
func apply_on_turn_end(_monster: Monster) -> void:
	pass
	
func modify_stat(_stat: String, base_value: int) -> int:
	return base_value
	
func can_act(_monster: Monster) -> bool:
	return true
	
func tick() -> bool:
	if duration == -1:
		return false
	turns_remaining -= 1
	return turns_remaining <= 0
