extends Node

var ui_stack: Array[Node] = []
var current_context: String = ""
#region Scene Constants
const SCENE_DIALOGUE := "dialogue"
const SCENE_BATTLE := "battle"
const SCENE_BATTLE_OPTIONS := "battle_options"
const SCENE_BATTLE_MOVES := "battle_moves"
const SCENE_MENU := "menu"
const SCENE_PARTY := "party"
const SCENE_PARTY_OPTIONS := "party_options"
const SCENE_INVENTORY := "inventory"
const SCENE_INVENTORY_OPTIONS := "inventory_options"
#endregion
#region Scenes
var dialogue_scene := preload("res://scenes/ui/dialogue/dialogue_box.tscn")
var battle_scene := preload("res://scenes/battle/single/battle_3.tscn")
var battle_options_scene := preload("res://scenes/battle/single/options_3.tscn")
var battle_moves_scene := preload("res://scenes/battle/single/single_moves.tscn")
var menu_scene := preload("res://scenes/ui/menu/menu.tscn")
var party_scene := preload("res://scenes/ui/party/party.tscn")
var party_options_scene := preload("res://scenes/ui/party/options.tscn")
var inventory_scene := preload("res://scenes/ui/inventory/inventory.tscn")
var inventory_options_scene := preload("res://scenes/ui/inventory/options.tscn")
#endregion
#region Scenes Dictionary
var scenes: Dictionary = {
	SCENE_DIALOGUE: preload("res://scenes/ui/dialogue/dialogue_box.tscn"),
	SCENE_BATTLE: preload("res://scenes/battle/single/battle_3.tscn"),
	SCENE_BATTLE_OPTIONS: preload("res://scenes/battle/single/options_3.tscn"),
	SCENE_BATTLE_MOVES: preload("res://scenes/battle/single/single_moves.tscn"),
	SCENE_MENU: preload("res://scenes/ui/menu/menu.tscn"),
	SCENE_PARTY: preload("res://scenes/ui/party/party.tscn"),
	SCENE_PARTY_OPTIONS: preload("res://scenes/ui/party/options.tscn"),
	SCENE_INVENTORY: preload("res://scenes/ui/inventory/inventory.tscn"),
	SCENE_INVENTORY_OPTIONS: preload("res://scenes/ui/inventory/options.tscn") }
#endregion
func _ready() -> void:
	EventBus.battle_manager_ready.connect(on_battle_ready)
	
func push_ui(scene: PackedScene):
	if scene == null:
		push_error("PackedScene is null! Scene not loaded correctly.")
		return null
	var ui = scene.instantiate()
	ui.layer = ui_stack.size() + 1
	add_child(ui)
	ui_stack.append(ui)
	return ui
	
func push_ui_by_name(scene_name: String, context: String = ""):
	print("push_ui_by_name context: ", context)
	if context != "" and context == current_context:
		return null
	if scenes.has(scene_name):
		return push_ui(scenes[scene_name])
	push_error("scene not found: ", scene_name)
	return null
	
func pop_ui(target: Node = null):
	if current_context != "":
		current_context = ""
	if ui_stack.is_empty():
		return
	var ui = target if target else ui_stack.pop_back()
	if ui_stack.has(ui):
		ui_stack.erase(ui)
	ui.queue_free()
	
	return ui
	
func clear_ui():
	print("clear_ui called")
	while ui_stack.size() > 0:
		pop_ui()
		print("ui_stack:", ui_stack)
	print("final ui_stack:", ui_stack)
	
func on_battle_ready():
	push_ui(battle_scene)
	
func fight_selected():
	push_ui(battle_moves_scene)
	
func party_selected():
	push_ui(party_scene)
	
func item_selected():
	push_ui(inventory_scene)
