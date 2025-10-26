extends CanvasLayer

@export var description_label: Label
@export var power_label: Label
@export var type_label: Label
@export var category_label: Label

var reordering: bool = false
var swap_index: int = -1

#region Move Slots
enum MoveSlot {MOVE0, MOVE1, MOVE2, MOVE3}

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
	display_move_labels()
	EventBus.toggle_labels.connect(toggle_description)
	
func _input(event: InputEvent) -> void:
	if self != UiManager.ui_stack.back():
		return
	
	if event.is_action_pressed("yes") \
	or event.is_action_pressed("no") or \
	event.is_action_pressed("up") or \
	event.is_action_pressed("down"):
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("yes"):
		if not reordering:
			_input_move()
		else:
			swap_moves(swap_index, v2_to_slot[selected_slot])
	if event.is_action_pressed("no"):
		if not reordering:
			close()
		else:
			cancel_swap()
	if event.is_action_pressed("menu"):
		if not reordering:
			reordering = true
			set_moving_slot()
			swap_index = v2_to_slot[selected_slot]
		else:
			cancel_swap()
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
	if not reordering:
		set_active_slot()
	else:
		set_moving_slot()
	display_move_labels()
	
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
	move0_label.text = BattleManager.player_actor.moves[0].name \
	if BattleManager.player_actor.moves.size() > 0 else ""
	move1_label.text = BattleManager.player_actor.moves[1].name if \
	BattleManager.player_actor.moves.size() > 1 else ""
	move2_label.text = BattleManager.player_actor.moves[2].name if \
	BattleManager.player_actor.moves.size() > 2 else ""
	move3_label.text = BattleManager.player_actor.moves[3].name if \
	BattleManager.player_actor.moves.size() > 3 else ""
	
func swap_moves(from_index: int, to_index: int) -> void:
	print("would move %s to %s" % [from_index, to_index])
	
	var monster = BattleManager.player_actor
	
	var temp = monster.moves[from_index]
	monster.moves[from_index] = monster.moves[to_index]
	monster.moves[to_index] = temp
	
	reordering = false
	swap_index = -1
	set_active_slot()
	update_moves()
	
func cancel_swap():
	reordering = false
	swap_index = -1
	set_active_slot()
	
func display_move_labels():
	var monster = PartyManager.party[0]
	print("monster: ", monster)
	var moves = monster.moves
	var move = moves[v2_to_slot[selected_slot]]
	print("move: ", move.name)
	var description = move.description
	description_label.text = description
	power_label.text = move.get_move_power()
	type_label.text = move.type
	var move_category = move.get_move_damage_category()
	var move_category_label = "PHYS" if move_category == "PHYSICAL" else "SPEC"
	category_label.text = move_category_label
	
func toggle_description():
	for label in [description_label, power_label, type_label, category_label]:
		label.visible = !label.visible
