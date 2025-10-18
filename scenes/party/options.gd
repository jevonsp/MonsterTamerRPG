extends CanvasLayer

signal option_chosen(slot_enum)

@export var processing: bool = false

enum Slot {SLOT0, SLOT1, SLOT2, SLOT3}
var selected_slot: Slot = Slot.SLOT0

@onready var slot: Dictionary = {
	Slot.SLOT0: $Slot0/Background,
	Slot.SLOT1: $Slot1/Background,
	Slot.SLOT2: $Slot2/Background,
	Slot.SLOT3: $Slot3/Background }
@onready var slot_dict: Dictionary = {
	0: Slot.SLOT0,
	1: Slot.SLOT1,
	2: Slot.SLOT2,
	3: Slot.SLOT3 }

func _ready() -> void:
	set_active_slot()
	processing = true
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("yes") \
	or event.is_action_pressed("no") or \
	event.is_action_pressed("up") or \
	event.is_action_pressed("down"):
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("yes"):
		_input_selection()
	if event.is_action_pressed("no"):
		option_chosen.emit(Slot.SLOT3)
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
	print(selected_slot)
	
func _input_selection():
	option_chosen.emit(selected_slot)
	close()
	
func unset_active_slot():
	slot[selected_slot].frame = 0
	
func set_active_slot():
	slot[selected_slot].frame = 1
	
func close():
	get_parent().remove_child(self)
	queue_free()
	
func _on_party_options_open():
	processing = false
	
func _on_party_options_closed():
	processing = true
