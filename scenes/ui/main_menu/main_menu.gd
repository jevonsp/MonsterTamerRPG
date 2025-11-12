extends Node2D

const TILE_WIDTH: int = 160

enum Slot {SLOT0, SLOT1, SLOT2}
var selected_slot: Slot = Slot.SLOT0

var choices_limited: bool = false

var game := preload("res://scenes/world/maps/world/main_map.tscn")

@onready var slot: Dictionary = {
	Slot.SLOT0: $Slot0,
	Slot.SLOT1: $Slot1,
	Slot.SLOT2: $Slot2 }
@onready var slot_dict: Dictionary = {
	0: Slot.SLOT0,
	1: Slot.SLOT1,
	2: Slot.SLOT2 }

func _ready() -> void:
	if not FileAccess.file_exists("user://savegame.tres"):
		choices_limited = true
		selected_slot = Slot.SLOT1
	set_active_slot()
	
func _input(event: InputEvent) -> void:
	if not UiManager.ui_stack.is_empty():
		return
		
	if event.is_action_pressed("yes") \
	or event.is_action_pressed("no") or \
	event.is_action_pressed("up") or \
	event.is_action_pressed("down"):
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("yes"):
		_input_selection()
	if event.is_action_pressed("no"):
		pass
	if event.is_action_pressed("up"):
		_move(-1)
	if event.is_action_pressed("down"):
		_move(1)
	
func _move(direction: int):
	unset_active_slot()
	if not choices_limited:
		selected_slot = (selected_slot + direction) % Slot.size() as Slot
		if selected_slot < 0: selected_slot = (Slot.size() - 1) as Slot
	set_active_slot()
	
func _input_selection():
	match selected_slot:
		0: 
			var loaded_game = game.instantiate()
			get_tree().root.add_child(loaded_game)
			SaverLoader.load_game()
			queue_free()
		1: 
			get_tree().change_scene_to_packed(game)
		2: 
			var choice = await DialogueManager.show_choice("Do you really want to delete your save?")
			if choice:
				var second_choice = await DialogueManager.show_choice("Are you absolutely sure? This is permanent!")
				if second_choice:
					DirAccess.remove_absolute("user://savegame.tres")
					DialogueManager.show_dialogue("Save file deleted.")
					unset_active_slot()
					choices_limited = true
					selected_slot = Slot.SLOT1
					set_active_slot()
					
func unset_active_slot():
	slot[selected_slot].region_rect.position.x = 0
	if choices_limited:
		slot[Slot.SLOT0].modulate = Color(0.5, 0.5, 0.5, 0.5)
		slot[Slot.SLOT2].modulate = Color(0.5, 0.5, 0.5, 0.5)
	
func set_active_slot():
	slot[selected_slot].region_rect.position.x = TILE_WIDTH
	if choices_limited:
		slot[Slot.SLOT0].modulate = Color(0.5, 0.5, 0.5, 0.5)
		slot[Slot.SLOT2].modulate = Color(0.5, 0.5, 0.5, 0.5)
