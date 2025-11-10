class_name Stopper extends EncounterZone

@export var is_active: bool = true

func setup():
	add_to_group("can_save")
	
func _on_step_completed(pos: Vector2):
	if not is_active:
		return
	if shape and check_position(pos):
		trigger(pos)
