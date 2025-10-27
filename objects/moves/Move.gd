class_name Move extends Resource

@export var name: String = ""
@export var icon: Texture2D
@export var description: String = ""
@export var accuracy: int = 100
@export var max_pp: int = 10

@export_enum("FIRE", "WATER", "GRASS", "LIGHT", "DARK", "NONE") var type = "NONE"
@export_range(-7, 7) var priority: int = 0

@export_subgroup("Animation")
@export_enum("ACTOR", "TARGET", "THROWN", "CENTER") var animation_type = "CENTER"
@export var still: bool = false
@export var animation: PackedScene
@export var sprite: Texture2D

@export_subgroup("Target Type")
@export_enum("ENEMY", "ALLY") var target_type: String = "ENEMY"
@export var chooses_targets: bool = false

@export_subgroup("Effects")
@export var effects: Array[BattleEffect] = []

func get_move_power() -> String:
	for effect in effects:
		if effect.name == "DAMAGE":
			return str (effect.base_power)
	return "-"
	
func get_move_damage_category() -> String:
	for effect in effects:
		if effect.name == "DAMAGE":
			return effect.damage_category
	return "-"
