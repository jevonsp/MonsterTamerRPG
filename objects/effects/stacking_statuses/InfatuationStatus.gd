class_name InfatuationStatus extends StatusEffect

func _init() -> void:
	name = "INFATUATION"
	duration = randi_range(1, 3)
	
func can_act(_monster: Monster) -> bool:
	if randf() >= 0.5:
		return true
	return false
