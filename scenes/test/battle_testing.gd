extends Node2D

@export var testing: bool = false

@export_custom(PROPERTY_HINT_ENUM, 
"1, 2, 3"
) var player_selection: int

@export_range(1.0, 100.0, 1.0) var player_level: float = 1.0

@export_custom(PROPERTY_HINT_ENUM, 
"1, 2, 3"
) var enemy_selection: int

@export_range(1.0, 100.0, 1.0) var enemy_level: float = 1.0

@export_custom(PROPERTY_HINT_ENUM, 
"Wild, Trainer"
) var ai_selection: int

var monster = [
	preload("res://objects/move_refactor/test_mon/TestMon.tres")
]

var test_monster = [
	preload("res://objects/move_refactor/test_mon/TestMon.tres")
]

var ai_profiles = [
	preload("res://scenes/world/level_components/wild_zone/WildProfile1.tres"),
	preload("res://scenes/world/npcs/trainer/TrainerProfile1.tres")
]

var items = [
	preload("res://objects/move_refactor/item2/item_resources/Ball2.tres")
]

func _ready() -> void:
	create_battle()
	
func create_battle():
	var player_monster = monster[player_selection] if not testing else test_monster[player_selection]
	var enemy_monster = monster[enemy_selection]
	
	var profile = ai_profiles[ai_selection]
	AiManager.set_ai(profile, null)
	
	var player_instance = PartyManager.make_monster(player_monster, int(player_level))
	player_instance.name = "Player"
	var player_instance2 = PartyManager.make_monster(player_monster, int(player_level))
	player_instance2.name = "Player2"
	var enemy_instance = BattleManager.add_enemies([enemy_monster], [int(enemy_level)])
	enemy_instance.name = "Enemy"
	
	InventoryManager.add_items(items[0], 5)
	
	BattleManager.start_battle()
