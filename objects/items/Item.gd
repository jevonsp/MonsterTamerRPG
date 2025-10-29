class_name Item extends Resource

@export var name: String = ""
@export var icon: Texture2D
@export var value: int = 100

@export_subgroup("Flags")
@export var in_battle_only: bool = true
@export var is_held: bool = false
@export var key_item: bool = false

@export_subgroup("Animation")
@export_enum("ACTOR", "TARGET", "THROWN", "CENTER") var animation_type = "CENTER"
@export var still: bool = false
@export var animation: PackedScene
@export var sprite: PackedScene

@export_subgroup("Target Type")
@export_enum("ENEMY", "ALLY") var target_type: String = "ENEMY"
@export var chooses_targets: bool = false

@export_subgroup("Effects")
@export var effects: Array[BattleEffect] = []

@export_subgroup("Hold Effects")
@export_range(-7, 7) var priority: int = 0
@export var hold_effects: Array[HoldEffect] = []

@export_subgroup("Descriptions")
@export var short_description: String = ""
@export var long_description: String = ""
