class_name MoveEffect extends Resource

@export_subgroup("Target Type")
@export_enum("ENEMY", "ALLY", "SELF", "ENEMIES", "ALLIES", "ALL") var target_type: String = "ENEMY"

func apply(_actor: Monster, _target: Monster, _move: Move) -> void:
	pass
