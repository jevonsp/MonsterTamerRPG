class_name AiProfile extends Resource

@export_enum("WILD", "TRAINER") var battle_type
@export_enum("AGGRESSIVE", "BALANCED", "DEFENSIVE") var strategy
#region Items
@export_enum("NONE", "HEALING", "ALL") var item_usage
@export var inventory: Array[Item] = []
@export var item_quant: Array[int] = []
#endregion
@export_enum("TYPE_ADVANTAGE", "HIGHEST_POWER", "RANDOM") var move_preference
@export_enum("NEVER", "ON_WEAKNESS", "ON_LOW_HP") var switching_behavor

@export var heal_hp_threshold: float = 30.0
@export var switch_hp_threshold: float = 20.0
