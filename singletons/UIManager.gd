extends Node

var ui_stack: Array[Node] = []

#region Scenes
var dialogue_scene := preload("res://scenes/ui/dialogue/dialogue_box.tscn")
var battle_scene2 := preload("res://scenes/battle/single/battle2.tscn")
var battle_options_scene := preload("res://scenes/battle/single/single_options.tscn")
var battle_moves_scene := preload("res://scenes/battle/single/single_moves.tscn")
var menu_scene := preload("res://scenes/ui/menu/menu.tscn")
var party_scene := preload("res://scenes/ui/party/party.tscn")
var party_options_scene := preload("res://scenes/ui/party/options.tscn")
var inventory_scene := preload("res://scenes/ui/inventory/inventory.tscn")
var inventory_options_scene := preload("res://scenes/ui/inventory/options.tscn")
#endregion

func _ready() -> void:
	print("battle_scene2: ", battle_scene2)
	print("battle_scene2.resource_path:  ", battle_scene2.resource_path)
	
func push_ui(scene: PackedScene):
	print("scene: ", scene)
	var ui = scene.instantiate()
	if ui == null:
		print("Error path invalid: ", scene.resource_path)
	add_child(ui)
	ui_stack.append(ui)
	print("stack added: ", ui)
		
	return ui
	
func pop_ui(target: Node = null):
	if ui_stack.is_empty():
		return
	var ui = target if target else ui_stack.pop_back()
	if ui_stack.has(ui):
		ui_stack.erase(ui)
	ui.queue_free()
	print("stack removed: ", ui)
	
	return ui
