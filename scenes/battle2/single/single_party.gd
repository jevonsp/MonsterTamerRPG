extends CanvasLayer

enum PartySlot {SLOT0, SLOT1, SLOT2, SLOT3, SLOT4, SLOT5}

@export var processing: bool = false

var selected_slot: Vector2 = Vector2(0,0)
var last_selected: Vector2
var v2_to_slot: Dictionary = {
	Vector2(0,0): PartySlot.SLOT0,
	Vector2(1,0): PartySlot.SLOT1,
	Vector2(1,1): PartySlot.SLOT2,
	Vector2(1,2): PartySlot.SLOT3,
	Vector2(1,3): PartySlot.SLOT4,
	Vector2(1,4): PartySlot.SLOT5 }
	
@onready var slot: Dictionary = {
	PartySlot.SLOT0: $Slot0/Background,
	PartySlot.SLOT1: $Slot1/Background,
	PartySlot.SLOT2: $Slot2/Background,
	PartySlot.SLOT3: $Slot3/Background,
	PartySlot.SLOT4: $Slot4/Background,
	PartySlot.SLOT5: $Slot5/Background }

func _ready() -> void:
	processing = true
	set_active_slot()
	
func _input(event: InputEvent) -> void:
	if not processing:
		return
	if event.is_action_pressed("yes"):
		_input_selection()
	if event.is_action_pressed("no"):
		close()
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
	var allowed = get_allowed_slots()
	var new_slot = selected_slot + direction
	
	if direction.x != 0:
		if selected_slot.x == 0 and direction.x > 0:
			new_slot.x = 1
			if last_selected:
				new_slot.y = last_selected.y
			new_slot.y = min(new_slot.y, get_allowed_slots()[-1].y)
		elif selected_slot.x == 1 and direction.x < 0:
			new_slot = Vector2(0,0)
			last_selected = selected_slot
	else:
		var column_slots = allowed.filter(func(v): return v.x == selected_slot.x)
		var ys = column_slots.map(func(v): return v.y)
		var index = ys.find(selected_slot.y)
		if index != -1:
			index += direction.y
			if index < 0:
				index = ys.size() - 1
			elif index >= ys.size():
				index = 0
			new_slot.y = ys[index]
	if new_slot in allowed:
		selected_slot = new_slot
	set_active_slot()
	
func get_allowed_slots() -> Array:
	var left = [Vector2(0, 0)]
	var right: Array = []
	var party_size = PartyManager.party.size()
	var right_slots = party_size - 1
	for i in range(right_slots):
		right.append(Vector2(1, i))
		
	return left + right
	
func _input_selection():
	pass
	
func _on_input_state_changed(new_state):
	match new_state:
		GameManager.InputState.OVERWORLD: pass
		GameManager.InputState.BATTLE:
			processing = true
		GameManager.InputState.DIALOGUE:
			processing = false
		GameManager.InputState.INACTIVE: pass
	
func get_curr_slot():
	return v2_to_slot[selected_slot]
	
func unset_active_slot():
	slot[get_curr_slot()].frame = 0
	
func set_active_slot():
	slot[get_curr_slot()].frame = 1
	
func set_moving_slot():
	slot[get_curr_slot()].frame = 2
	
func close():
	get_parent().remove_child(self)
	queue_free()
