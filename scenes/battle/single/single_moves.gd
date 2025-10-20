extends CanvasLayer

signal move_cancelled

@export var processing: bool = false

#region Move Slots
enum MoveSlot {MOVE0, MOVE1, MOVE2, MOVE3}
enum MoveState {PICKING, REORDERING}

var state = MoveState.PICKING

var selected_slot: Vector2 = Vector2(0,0)
var v2_to_slot: Dictionary = {
	Vector2(0,0): MoveSlot.MOVE0,
	Vector2(1,0): MoveSlot.MOVE1,
	Vector2(0,1): MoveSlot.MOVE2,
	Vector2(1,1): MoveSlot.MOVE3 }
	
@onready var slot: Dictionary = {
	MoveSlot.MOVE0: $Slot0/Background,
	MoveSlot.MOVE1: $Slot1/Background,
	MoveSlot.MOVE2: $Slot2/Background,
	MoveSlot.MOVE3: $Slot3/Background }
	
@onready var move0_label = $Slot0/Background/Label
@onready var move1_label = $Slot1/Background/Label
@onready var move2_label = $Slot2/Background/Label
@onready var move3_label = $Slot3/Background/Label
#endregion

func _ready() -> void:
	if UiManager.ui_stack.is_empty():
		UiManager.ui_stack.append(self)
	set_active_slot()
	update_moves()
	
func _input(event: InputEvent) -> void:
	if self != UiManager.ui_stack.back():
		return
	if event.is_action_pressed("yes"):
		_input_move()
	if event.is_action_pressed("no"):
		print("no pressed")
		match state:
			MoveState.PICKING:
				close()
			MoveState.REORDERING:
				pass
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
	var allowed = get_allowed_moves()
	var new_slot = selected_slot + direction
	new_slot.x = clamp(new_slot.x, 0, 1)
	new_slot.y = clamp(new_slot.y, 0, 1)
	if new_slot in allowed:
		selected_slot = new_slot
	set_active_slot()
	
func get_allowed_moves() -> Array:
	if not BattleManager.in_battle:
		return [Vector2(0,0), Vector2(1,0), Vector2(0,1), Vector2(1,1)]
	var moves = PartyManager.get_first_alive().moves
	var move_count = moves.size()
	var allowed = []
	
	var pos_order = [Vector2(0,0), Vector2(1,0), Vector2(0,1), Vector2(1,1)]
	
	for i in range(move_count):
		allowed.append(pos_order[i])
	print("allowed: ", allowed)
	return allowed
	
func _input_move():
	if not processing:
		return
	var current_slot = get_curr_slot()
	var move_data 
	if PartyManager.get_first_alive():
		move_data = PartyManager.get_first_alive().moves[current_slot]
	
	if move_data == null:
		print("No move in this slot!")
		return
	
	print("Selected move: ", move_data.name)
	var action = MoveAction.new(BattleManager.player_actor, [BattleManager.enemy_actor], move_data)
	BattleManager.on_action_selected(action)
	
func get_curr_slot():
	return v2_to_slot[selected_slot]
	
func unset_active_slot():
	slot[get_curr_slot()].frame = 0
	
func set_active_slot():
	slot[get_curr_slot()].frame = 1
	
func set_moving_slot():
	slot[get_curr_slot()].frame = 2
	
func close() -> void:
	UiManager.pop_ui(self)
	
func update_moves():
	pass
	
