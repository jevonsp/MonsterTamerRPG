extends CanvasLayer

const TILE_WIDTH: int = 160
const GRID_WIDTH = 6
const GRID_HEIGHT = 5
const BOX_SLOTS = GRID_HEIGHT * GRID_WIDTH

enum Slot { SLOT0, SLOT1, SLOT2, SLOT3, SLOT4, SLOT5, SLOT6, SLOT7, SLOT8, SLOT9,
			SLOT10, SLOT11, SLOT12, SLOT13, SLOT14, SLOT15, SLOT16, SLOT17, SLOT18, SLOT19,
			SLOT20, SLOT21, SLOT22, SLOT23, SLOT24, SLOT25, SLOT26, SLOT27, SLOT28, SLOT29 }

enum Box { BOX0, BOX1, BOX2, BOX3, BOX4, BOX5, BOX6, BOX7, BOX8, BOX9 }

@export var grid: GridContainer

var selected_slot: Vector2 = Vector2(0,0)
var v2_to_slot: Dictionary = {}

var selected_box: int = 0

var reordering: bool = false

@onready var slot: Dictionary = {}

var preload_monster

func _ready() -> void:
	if UiManager.ui_stack.is_empty():
		UiManager.ui_stack.append(self)
	
	# Build v2_to_slot dictionary
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var index = y * GRID_WIDTH + x
			v2_to_slot[Vector2(x, y)] = Slot.values()[index]

	# Build slot dictionary (assuming your nodes are named Slot0, Slot1, etc.)
	for i in range(GRID_WIDTH * GRID_HEIGHT):
		var slot_node = grid.get_node_or_null("Slot" + str(i))
		if slot_node:
			slot[Slot.values()[i]] = slot_node
			
	preload_monster = load("res://objects/monsters/pistol_shrimp/Pistol_Shrimp.tres")
			
	for i in range(0, 30):
		PartyManager.make_monster(preload_monster, 5)
		
	for i in range(0, 30):
		if PartyManager.storage[i] == null:
			continue
		print("storage monster %s: %s" % [i, PartyManager.storage[i].name])
			
	set_active_slot()
	display_mini_monsters()
	display_hovered()
	
func _input(event: InputEvent) -> void:
	if self != UiManager.ui_stack.back():
		return
	
	if event.is_action_pressed("yes") \
	or event.is_action_pressed("no") or \
	event.is_action_pressed("up") or \
	event.is_action_pressed("down"):
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("up"):
		_move(Vector2.UP)
	if event.is_action_pressed("down"):
		_move(Vector2.DOWN)
	if event.is_action_pressed("left"):
		_move(Vector2.LEFT)
	if event.is_action_pressed("right"):
		_move(Vector2.RIGHT)
		
	if event.is_action_pressed("L"):
		_shift(-1)
		
	if event.is_action_pressed("R"):
		_shift(1)
		
	if event.is_action_pressed("yes"):
		if not reordering:
			_open_options()
	
func _move(direction: Vector2):
	unset_active_slot()
	var new_slot = selected_slot + direction
	new_slot.x = clamp(new_slot.x, 0, GRID_WIDTH - 1)
	new_slot.y = clamp(new_slot.y, 0, GRID_HEIGHT - 1)
	selected_slot = new_slot

	if not reordering:
		set_active_slot()
	else:
		set_moving_slot()
		
	print("selected_box: ", selected_box)
	var monster_slot: int = (selected_box * (BOX_SLOTS)) + int(selected_slot.y * GRID_WIDTH + selected_slot.x)
	print("monster_slot: ", monster_slot)
	
	display_hovered()
	
func _shift(direction: int):
	selected_box = (selected_box + direction) % Box.size() as Box
	if selected_box < 0: selected_box = (Box.size() - 1) as Box
	print("selected_box:", selected_box)
	var monster_slot: int = (selected_box * (BOX_SLOTS)) + int(selected_slot.y * GRID_WIDTH + selected_slot.x)
	print("monster_slot: ", monster_slot)
	display_mini_monsters()
	display_hovered()
	
func get_curr_slot():
	return v2_to_slot[selected_slot]
	
func unset_active_slot():
	slot[get_curr_slot()].region_rect.position.x = 0
	
func set_active_slot():
	slot[get_curr_slot()].region_rect.position.x = TILE_WIDTH
	
func set_moving_slot():
	slot[get_curr_slot()].region_rect.position.x = TILE_WIDTH * 2
	
func _open_options():
	var options = UiManager.push_ui(UiManager.storage_options_scene)
	if not options.option_chosen.is_connected(_on_option_chosen):
		options.option_chosen.connect(_on_option_chosen)
		
func _on_option_chosen(slot_enum: int):
	print("got slot_enum: ", slot_enum)
	
func display_hovered():
	var monster_slot = (selected_box * (BOX_SLOTS)) + (selected_slot.y * GRID_WIDTH + selected_slot.x)
	print("would display monster %s as big" % monster_slot)
	
func display_mini_monsters():
	var start_index: int = selected_box * (BOX_SLOTS)
	var end_index: int = start_index + (BOX_SLOTS) - 1
	print("would display monsters %s to %s" % [start_index, end_index])
	
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var slot_index = y * GRID_WIDTH + x
			print("slot index: ", slot_index)
			var monster_index = start_index + slot_index
			print("monster slot: ", monster_index)
			var slot_node = slot[Slot.values()[slot_index]]
			print("slot_node: ", slot_node.name)
			var storage = PartyManager.storage
			if monster_index < storage.size() and storage[monster_index] != null:
				display_monster_in_slot(slot_node, storage[monster_index])
			else:
				display_empty_slot(slot_node)
			
func display_monster_in_slot(slot_node: Node, monster: Monster):
	print("would display %s in %s" % [monster.name, slot_node.name])
	slot_node.get_node("MiniPortrait").texture = monster.species.sprite
	
func display_empty_slot(slot_node):
	print("would display empty in %s" % slot_node)
	slot_node.get_node("MiniPortrait").texture = null
