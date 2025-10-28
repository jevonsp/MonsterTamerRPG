extends CanvasLayer

signal option_chosen(slot_enum)

const TILE_WIDTH: int = 160

enum Slot {SLOT0, SLOT1, SLOT2, SLOT3, SLOT4}

@export var processing: bool = false

var selected_slot: Slot = Slot.SLOT0

@onready var slot: Dictionary = {
	Slot.SLOT0: $Slot0,
	Slot.SLOT1: $Slot1,
	Slot.SLOT2: $Slot2,
	Slot.SLOT3: $Slot3,
	Slot.SLOT4: $Slot4 }
@onready var slot_dict: Dictionary = {
	0: Slot.SLOT0,
	1: Slot.SLOT1,
	2: Slot.SLOT2,
	3: Slot.SLOT3,
	4: Slot.SLOT4 }
	
func _ready() -> void:
	if UiManager.ui_stack.is_empty():
		UiManager.ui_stack.append(self)
	set_active_slot()
	
func _input(event: InputEvent) -> void:
	if UiManager.ui_stack.back() != self:
		return
		
	if event.is_action_pressed("yes") \
	or event.is_action_pressed("no") or \
	event.is_action_pressed("up") or \
	event.is_action_pressed("down"):
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("yes"):
		_input_selection()
	if event.is_action_pressed("no"):
		close()
	if event.is_action_pressed("up"):
		_move(-1)
	if event.is_action_pressed("down"):
		_move(1)
	
func _move(direction: int):
	unset_active_slot()
	selected_slot = (selected_slot + direction) % Slot.size() as Slot
	if selected_slot < 0: selected_slot = (Slot.size() - 1) as Slot
	set_active_slot()
	
func unset_active_slot():
	slot[selected_slot].region_rect.position.x = 0
	
func set_active_slot():
	slot[selected_slot].region_rect.position.x = TILE_WIDTH
	
func _input_selection():
	match selected_slot:
		0: 
			print("selected_slot:", selected_slot)
			option_chosen.emit(selected_slot)
			close()
		1:
			print("selected_slot:", selected_slot)
			option_chosen.emit(selected_slot)
			close()
		2: 
			print("selected_slot:", selected_slot)
			option_chosen.emit(selected_slot)
			close()
		3:
			print("selected_slot:", selected_slot)
			option_chosen.emit(selected_slot)
			close()
		4: 
			close()
		
func close():
	get_parent().remove_child(self)
	UiManager.pop_ui(self)
