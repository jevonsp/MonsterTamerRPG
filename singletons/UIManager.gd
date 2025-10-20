extends Node

var processing: bool = true

var battle_scene = preload("res://scenes/battle2/single/single_battle.tscn")
var menu_scene = preload("res://scenes/menu/menu.tscn")
var party_scene = preload("res://scenes/party/single_party.tscn")
var party_options_scene = preload("res://scenes/party/options.tscn")
var inventory_scene = preload("res://scenes/inventory/inventory.tscn")
var inventory_options_scene = preload("res://scenes/inventory/options.tscn")

func _ready() -> void:
	GameManager.input_state_changed.connect(_on_input_state_changed)
	
func _input(event: InputEvent) -> void:
	if not processing:
		return
	if event.is_action_pressed("menu"):
		if get_tree().get_first_node_in_group("player").is_moving:
			return
		GameManager.input_state = GameManager.InputState.MENU
		show_menu()
	
func _on_input_state_changed(new_state) -> void:
	match new_state:
		GameManager.InputState.OVERWORLD:
			processing = true
		GameManager.InputState.BATTLE:
			processing = false
		GameManager.InputState.DIALOGUE:
			processing = false
		GameManager.InputState.MENU:
			processing = true
		GameManager.InputState.INACTIVE:
			pass

func show_battle():
	var battle = battle_scene.instantiate()
	add_child(battle)
	return battle
	
func show_menu():
	var menu = menu_scene.instantiate()
	add_child(menu)
	return menu
	
func show_party():
	var party = party_scene.instantiate()
	add_child(party)
	return party
	
func show_party_options():
	var party_options = party_options_scene.instantiate()
	add_child(party_options)
	return party_options
	
func show_inventory():
	var inventory = inventory_scene.instantiate()
	add_child(inventory)
	return inventory
	
func show_inventory_options():
	var inventory_options = inventory_options_scene.instantiate()
	add_child(inventory_options)
	return inventory_options
	
