extends Node

@onready var game_root = $"."

func save_game():
	var saved_game: SavedGame = SavedGame.new()
	
	var player = get_tree().get_first_node_in_group("player")
	
	saved_game.player_position = player.global_position
	
	saved_game.player_party = PartyManager.party
	saved_game.player_storage = PartyManager.storage
	saved_game.inventory = InventoryManager.inventory
	
	saved_game.story_flags = StoryManager.story_flags
	saved_game.tutorial_progress = StoryManager.tutorial_progress
	
	var saved_data: Array[SavedData] = []
	get_tree().call_group("can_save", "on_save_game", saved_data)
	saved_game.saved_data = saved_data
	
	ResourceSaver.save(saved_game, "user://savegame.tres")
	
func load_game():
	var saved_game: SavedGame = ResourceLoader.load("user://savegame.tres") as SavedGame
	
	var player = get_tree().get_first_node_in_group("player")
	
	player.global_position = saved_game.player_position
	PartyManager.party = saved_game.player_party
	for i in range(PartyManager.party.size()):
		var monster = PartyManager.party[i]
		print("Monster ", i, ": ", monster.name, " species: ", monster.species)
	PartyManager.storage = saved_game.player_storage
	InventoryManager.inventory = saved_game.inventory
	
	get_tree().call_group("can_save", "on_before_load_game")
	get_tree().call_group("can_save", "on_load_game", saved_game.saved_data)
	
