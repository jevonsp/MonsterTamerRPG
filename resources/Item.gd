class_name Item extends Resource

@export var name: String = ""
@export var sprite: Texture2D
@export_range(-7, 7) var priority: int = 0

@export_subgroup("Animation")
@export_enum("ACTOR", "TARGET", "THROWN", "CENTER") var animation_type = "CENTER"
@export var animation: PackedScene

@export_subgroup("Target Type")
@export_enum("ENEMY", "ALLY") var target_type: String = "ALLY"
@export var chooses_targets: bool = false

@export_subgroup("Effects")
@export var effects: Array[ItemEffect] = []
