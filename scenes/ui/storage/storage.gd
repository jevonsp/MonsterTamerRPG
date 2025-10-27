extends CanvasLayer

enum Slot {SLOT0, SLOT1, SLOT2, SLOT3, SLOT4, SLOT5, SLOT6, SLOT7, SLOT8, SLOT9,
			SLOT10, SLOT11, SLOT12, SLOT13, SLOT14, SLOT15, SLOT16, SLOT17, SLOT18, SLOT19,
			SLOT20, SLOT21, SLOT22, SLOT23, SLOT24, SLOT25, SLOT26, SLOT27, SLOT28, SLOT29}

const TILE_WIDTH: int = 160
const GRID_WIDTH = 6
const GRID_HEIGHT = 5

@export var grid: GridContainer

var selected_slot: Vector2 = Vector2(0,0)
var v2_to_slot: Dictionary = {}

var reordering: bool = false

@onready var slot: Dictionary = {}

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
			
	set_active_slot()
	
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
	
func get_curr_slot():
	return v2_to_slot[selected_slot]
	
func unset_active_slot():
	slot[get_curr_slot()].region_rect.position.x = 0
	
func set_active_slot():
	slot[get_curr_slot()].region_rect.position.x = TILE_WIDTH
	
func set_moving_slot():
	slot[get_curr_slot()].region_rect.position.x = TILE_WIDTH * 2
