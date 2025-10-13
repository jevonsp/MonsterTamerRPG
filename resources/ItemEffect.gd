class_name ItemEffect extends Resource

@export_subgroup("Target Type")
@export_enum("ENEMY", "ALLY", "SELF", "ENEMIES", "ALLIES", "ALL") var target_type: String = "ALLY"

func apply(_actor: Monster, _target: Monster, _item: Item) -> void:
	pass
