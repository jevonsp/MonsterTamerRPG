extends Node

var ui_stack: Array[Node] = []
var context: String = "":
	get:
		return context
	set(new_context):
		context = new_context

#region Scene Constants
const SCENE_DIALOGUE := "dialogue"
const SCENE_CHOICE := "choice"
const SCENE_SUMMARY := "summary"
const SCENE_BATTLE := "battle"
const SCENE_BATTLE_OPTIONS := "battle_options"
const SCENE_BATTLE_MOVES := "battle_moves"
const SCENE_MENU := "menu"
const SCENE_PARTY := "party"
const SCENE_PARTY_OPTIONS := "party_options"
const SCENE_INVENTORY := "inventory"
const SCENE_INVENTORY_OPTIONS := "inventory_options"
const SCENE_STORAGE := "storage"
const SCENE_STORAGE_OPTIONS := "storage_options"
#endregion
#region Scenes
var dialogue_scene := preload("res://scenes/ui/dialogue/dialogue_box.tscn")
var choice_scene := preload("res://scenes/ui/dialogue/yes_no_box.tscn")
var summary_scene := preload("res://scenes/ui/summary/summary.tscn")
var battle_scene := preload("res://scenes/battle/single/battle_3.tscn")
var battle_options_scene := preload("res://scenes/battle/single/options_3.tscn")
var battle_moves_scene := preload("res://scenes/battle/single/single_moves.tscn")
var menu_scene := preload("res://scenes/ui/menu/menu.tscn")
var party_scene := preload("res://scenes/ui/party/party.tscn")
var party_options_scene := preload("res://scenes/ui/party/options.tscn")
var inventory_scene := preload("res://scenes/ui/inventory/inventory.tscn")
var inventory_options_scene := preload("res://scenes/ui/inventory/options.tscn")
var storage_scene := preload("res://scenes/ui/storage/storage.tscn")
var storage_options_scene := preload("res://scenes/ui/storage/options.tscn")
#endregion
#region Scenes Dictionary
var scenes: Dictionary = {
	SCENE_DIALOGUE: preload("res://scenes/ui/dialogue/dialogue_box.tscn"),
	SCENE_CHOICE: preload("res://scenes/ui/dialogue/yes_no_box.tscn"),
	SCENE_SUMMARY: preload("res://scenes/ui/summary/summary.tscn"),
	SCENE_BATTLE: preload("res://scenes/battle/single/battle_3.tscn"),
	SCENE_BATTLE_OPTIONS: preload("res://scenes/battle/single/options_3.tscn"),
	SCENE_BATTLE_MOVES: preload("res://scenes/battle/single/single_moves.tscn"),
	SCENE_MENU: preload("res://scenes/ui/menu/menu.tscn"),
	SCENE_PARTY: preload("res://scenes/ui/party/party.tscn"),
	SCENE_PARTY_OPTIONS: preload("res://scenes/ui/party/options.tscn"),
	SCENE_INVENTORY: preload("res://scenes/ui/inventory/inventory.tscn"),
	SCENE_INVENTORY_OPTIONS: preload("res://scenes/ui/inventory/options.tscn"),
	SCENE_STORAGE: preload("res://scenes/ui/storage/storage.tscn"),
	SCENE_STORAGE_OPTIONS: preload("res://scenes/ui/storage/options.tscn") }
#endregion

func _ready() -> void:
	pass
	
func push_ui(scene: PackedScene):
	print("tried to push scene: ", scene)
	if scene == null:
		push_error("PackedScene is null! Scene not loaded correctly.")
		return null
	var ui = scene.instantiate()
	ui.layer = ui_stack.size() + 1
	ui_stack.append(ui)
	add_child(ui)
	return ui
	
func pop_ui(target: Node = null):
	if ui_stack.is_empty():
		return
	var ui = target if target else ui_stack.pop_back()
	if ui_stack.has(ui):
		ui_stack.erase(ui)
	ui.queue_free()
	return ui
	
func push_ui_by_name(scene_name: String):
	print("push_ui_by_name context: ", context)
	if scenes.has(scene_name):
		print("pushing: ", scene_name)
		var ui = push_ui(scenes[scene_name])
		return ui
	push_error("scene not found: ", scene_name)
	return null
	
func clear_ui():
	print("clear_ui called")
	while ui_stack.size() > 0:
		pop_ui()
		print("ui_stack:", ui_stack)
	print("final ui_stack:", ui_stack)
