extends CanvasLayer

signal option_chosen(slot_enum: int)

var choices_limited: bool = false

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

func _ready():
	set_active_slot()
	if UiManager.ui_stack.is_empty():
		UiManager.ui_stack.append(self)
	EventBus.limit_choices.connect(_on_limit_choices)

func _input(event: InputEvent) -> void:
	if self != UiManager.ui_stack.back():
		return
	
	if event.is_action_pressed("yes") \
	or event.is_action_pressed("no") or \
	event.is_action_pressed("up") or \
	event.is_action_pressed("down"):
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("yes"):
		_input_selection()
		unlimit_choices()
	if event.is_action_pressed("no"):
		print("no pressed")
		option_chosen.emit(Slot.SLOT3)
		close()
	if event.is_action_pressed("up"):
		_move(-1)
	if event.is_action_pressed("down"):
		_move(1)
		
		
func _move(direction: int):
	unset_active_slot()
	if not choices_limited:
		selected_slot = (selected_slot + direction) % Slot.size() as Slot
		if selected_slot < 0: selected_slot = (Slot.size() - 1) as Slot
	else:
		if direction > 0:
			selected_slot = (selected_slot + 1) % 2 as Slot
		elif direction < 0:
			selected_slot = (selected_slot - 1) % 2 as Slot
			if selected_slot < 0: selected_slot = Slot.SLOT1
		elif selected_slot >= Slot.SLOT2:
			selected_slot = Slot.SLOT0
	set_active_slot()
	print(selected_slot)
	
func _input_selection():
	option_chosen.emit(selected_slot)
	close()
	
func unset_active_slot():
	slot[selected_slot].frame = 0
	if choices_limited:
		slot[Slot.SLOT2].modulate = Color(0.5, 0.5, 0.5, 0.5)
		slot[Slot.SLOT3].modulate = Color(0.5, 0.5, 0.5, 0.5)
	
func set_active_slot():
	slot[selected_slot].frame = 1
	if choices_limited:
		slot[Slot.SLOT2].modulate = Color(0.5, 0.5, 0.5, 0.5)
		slot[Slot.SLOT3].modulate = Color(0.5, 0.5, 0.5, 0.5)
		
func close():
	UiManager.pop_ui(self)
	
func _on_limit_choices():
	choices_limited = true
	slot[Slot.SLOT2].modulate = Color(0.5, 0.5, 0.5, 0.5)
	slot[Slot.SLOT3].modulate = Color(0.5, 0.5, 0.5, 0.5)
	
func unlimit_choices():
	choices_limited = false
	# Restore normal appearance
	slot[Slot.SLOT2].modulate = Color(1, 1, 1, 1)
	slot[Slot.SLOT3].modulate = Color(1, 1, 1, 1)
