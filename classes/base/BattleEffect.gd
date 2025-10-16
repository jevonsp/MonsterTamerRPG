class_name BattleEffect extends Resource

@export_subgroup("Target Type")
@export_enum("ENEMY", "ALLY", "SELF", "ENEMIES", "ALLIES", "ALL") var target_type: String = "ENEMY"

@export_subgroup("Animation")
@export_enum("ACTOR", "TARGET", "THROWN", "CENTER") var animation_type = "CENTER"
@export var animation: PackedScene

@export_subgroup("Sprite")
@export var sprite: Texture2D
@export var static_animation: bool = false

var actor
var target
var data

func apply(actor_ref: Monster, target_ref: Monster, data_ref) -> void:
	actor = actor_ref
	target = target_ref
	data = data_ref
	
