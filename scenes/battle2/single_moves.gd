extends CanvasLayer

signal move_cancelled

@export var processing: bool = false

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
	
func _ready() -> void:
	pass
	set_active_slot()
	
func _input(event: InputEvent) -> void:
	if not processing:
		return
	if event.is_action_pressed("yes"):
		_input_move()
	if event.is_action_pressed("no"):
		match state:
			MoveState.PICKING:
				move_cancelled.emit()
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
	selected_slot += direction
	selected_slot.x = clamp(selected_slot.x, 0, 1)
	selected_slot.y = clamp(selected_slot.y, 0, 1)
	set_active_slot()
	
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
	
func update_moves() -> void:
	pass
	
