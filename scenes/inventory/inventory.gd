extends CanvasLayer

const VISIBLE_SLOTS = 6
var processing: bool = false
var reordering: bool = false

enum Slot {SLOT0, SLOT1, SLOT2, SLOT3, SLOT4, SLOT5}
var cursor_index: Slot = Slot.SLOT0
var viewport_start: int = 0
var items: Array[Dictionary] = []

@onready var slot: Dictionary = {
	Slot.SLOT0: $Slot0/Background,
	Slot.SLOT1: $Slot1/Background,
	Slot.SLOT2: $Slot2/Background,
	Slot.SLOT3: $Slot3/Background,
	Slot.SLOT4: $Slot4/Background,
	Slot.SLOT5: $Slot5/Background }
@onready var slot_dict: Dictionary = {
	0: Slot.SLOT0,
	1: Slot.SLOT1,
	2: Slot.SLOT2,
	3: Slot.SLOT3,
	4: Slot.SLOT4,
	5: Slot.SLOT5 }
	
var potion_resource = preload("res://resources/items/Potion.tres")
var ball_resource = preload("res://resources/items/Ball.tres")
	
func _ready() -> void:
	set_active_slot()
	processing = true
	for item in InventoryManager.inventory:
		items.append(item)
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("yes") \
	or event.is_action_pressed("no") or \
	event.is_action_pressed("up") or \
	event.is_action_pressed("down"):
		get_viewport().set_input_as_handled()
	
	if not processing:
		return
	if event.is_action_pressed("yes"):
		if not reordering:
			pass
	if event.is_action_pressed("no"):
		if not reordering:
			close()
		else:
			cancel_swap()
			
	if event.is_action_pressed("up"):
		_move(-1)
	if event.is_action_pressed("down"):
		_move(1)
	
func _move(direction: int):
	unset_active_slot()
	var old_cursor = cursor_index
	var old_viewport = viewport_start
	const TESTING_SIZE: int = 7
	cursor_index = clamp(cursor_index + direction, 0, TESTING_SIZE - 1)
	print("cursor_index: ", cursor_index)
	if cursor_index == old_cursor:
		set_active_slot()
		return
	var relative_cursor_pos = cursor_index - viewport_start
	print("viewport_start", viewport_start)
	if relative_cursor_pos >= VISIBLE_SLOTS:
		viewport_start = cursor_index - VISIBLE_SLOTS + 1
	elif relative_cursor_pos < 0:
		viewport_start = cursor_index
	print("cursor_index after: ", cursor_index)
	
	var max_viewport = max(0, TESTING_SIZE - VISIBLE_SLOTS)
	viewport_start = clamp(viewport_start, 0, max_viewport)
	print("viewport_start after: ", viewport_start)
	
	if viewport_start != old_viewport:
		update_display()
		set_active_slot()
	else:
		set_active_slot()
	
	if not reordering:
		set_active_slot()
	else:
		set_moving_slot()
	
func get_ui_slot():
	var ui_index = cursor_index - viewport_start
	return slot_dict[ui_index]
	
func unset_active_slot():
	slot[get_ui_slot()].frame = 0
	
func set_active_slot():
	slot[get_ui_slot()].frame = 1
	
func set_moving_slot():
	slot[get_ui_slot()].frame = 2
	
func close():
	pass

func cancel_swap():
	pass
	
func update_display():
	print("update displays here")
