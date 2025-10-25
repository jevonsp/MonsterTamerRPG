extends CanvasLayer

enum MenuSlot {SLOT0, SLOT1, SLOT2, SLOT3, SLOT4}

@export var processing: bool = false

var selected_slot: MenuSlot = MenuSlot.SLOT0

@onready var slot: Dictionary = {
	MenuSlot.SLOT0: $Slot0/Background,
	MenuSlot.SLOT1: $Slot1/Background,
	MenuSlot.SLOT2: $Slot2/Background,
	MenuSlot.SLOT3: $Slot3/Background, 
	MenuSlot.SLOT4: $Slot4/Background }
@onready var slot_dict: Dictionary = {
	0: MenuSlot.SLOT0,
	1: MenuSlot.SLOT1,
	2: MenuSlot.SLOT2,
	3: MenuSlot.SLOT3, 
	4: MenuSlot.SLOT4 }

func _ready() -> void:
	processing = true
	set_active_slot()
	if UiManager.ui_stack.is_empty():
		UiManager.ui_stack.append(self)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("yes") \
	or event.is_action_pressed("no") or \
	event.is_action_pressed("up") or \
	event.is_action_pressed("down"):
		get_viewport().set_input_as_handled()
	if UiManager.ui_stack.is_empty():
		return
	if self != UiManager.ui_stack.back():
		return
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
	selected_slot = (selected_slot + direction) % MenuSlot.size() as MenuSlot
	if selected_slot < 0: selected_slot = (MenuSlot.size() - 1) as MenuSlot
	set_active_slot()
	
func _input_selection():
	if selected_slot == 0:
		UiManager.push_ui(UiManager.party_scene)
	elif selected_slot == 1:
		UiManager.push_ui(UiManager.inventory_scene)
	elif selected_slot == 2:
		print("caught pressed")
		print(selected_slot)
	elif selected_slot == 3:
		var choice = await DialogueManager.show_choice("Do you want to save the game")
		if choice:
			SaverLoader.save_game()
			DialogueManager.show_dialogue("Game saved!", true)
	elif selected_slot == 4:
		print("options pressed")
		print(selected_slot)
	else:
		print("somehow got out of bounds")
	
func unset_active_slot():
	slot[selected_slot].frame = 0
	
func set_active_slot():
	slot[selected_slot].frame = 1
	
func close():
	UiManager.pop_ui(self)
	UiManager.clear_ui()
	
