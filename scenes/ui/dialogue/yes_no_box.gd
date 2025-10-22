extends CanvasLayer

signal choice_selected(choice: bool)

enum Slot {SLOT0, SLOT1}
var selected_slot: Slot = Slot.SLOT0

@onready var slot: Dictionary = {
	Slot.SLOT0: $Slot0/Background,
	Slot.SLOT1: $Slot1/Background }
@onready var slot_dict: Dictionary = {
	0: Slot.SLOT0,
	1: Slot.SLOT1 }
	
func _ready() -> void:
	if UiManager.ui_stack.is_empty():
		UiManager.ui_stack.append(self)
	set_active_slot()
	
func _input(event: InputEvent) -> void:
	if self != UiManager.ui_stack.back():
		return
	
	if event.is_action_pressed("yes") \
	or event.is_action_pressed("no") or \
	event.is_action_pressed("up") or \
	event.is_action_pressed("down"):
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("yes"):
		input_selection(selected_slot)
	if event.is_action_pressed("no"):
	
		close()
	if event.is_action_pressed("up"):
		_move(-1)
	if event.is_action_pressed("down"):
		_move(1)
	
func _move(direction: int):
	unset_active_slot()
	if direction > 0:
		selected_slot = (selected_slot + 1) % 2 as Slot
	elif direction < 0:
		selected_slot = (selected_slot - 1) % 2 as Slot
		if selected_slot < 0: selected_slot = Slot.SLOT1
	set_active_slot()
	print(selected_slot)
	
func input_selection(slot_enum: int):
	print("slot_enum: ", slot_enum)
	var choice = (slot_enum == 0)
	choice_selected.emit(choice)
	close()
	
func unset_active_slot():
	slot[selected_slot].frame = 0
	
func set_active_slot():
	slot[selected_slot].frame = 1
	
func close():
	UiManager.pop_ui(self)
