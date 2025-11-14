extends Node2D

@export_custom(PROPERTY_HINT_ENUM, 
"PistolShrimp, PyroBadger, FoxMcLeaf"
) var player_selection: int

@export_range(1.0, 100.0, 1.0) var player_level: float = 1.0

@export_custom(PROPERTY_HINT_ENUM, 
"PistolShrimp, PyroBadger, FoxMcLeaf"
) var enemy_selection: int

@export_range(1.0, 100.0, 1.0) var enemy_level: float = 1.0

@export_custom(PROPERTY_HINT_ENUM, 
"Wild, Trainer"
) var ai_selection: int

var monster = [
	preload("res://objects/monsters/pistol_shrimp/Pistol_Shrimp.tres"),
	preload("res://objects/monsters/pyro_badger/Pyro_Badger.tres"),
	preload("res://objects/monsters/fox_mcleaf/Fox_McLeaf.tres")
]

var ai_profiles = [
	preload("res://scenes/world/level_components/wild_zone/WildProfile1.tres"),
	preload("res://scenes/world/npcs/trainer/TrainerProfile1.tres")
]

func _ready() -> void:
	create_battle()
	
func create_battle():
	var player_monster = monster[player_selection]
	var enemy_monster = monster[enemy_selection]
	var profile = ai_profiles[ai_selection]
	AiManager.set_ai(profile, null)
	PartyManager.make_monster(player_monster, int(player_level))
	BattleManager.add_enemies([enemy_monster], [int(enemy_level)])
	BattleManager.start_battle()
