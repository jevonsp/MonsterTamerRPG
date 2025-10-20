extends CanvasLayer

@export var processing: bool = false

enum MoveSlot {FIGHT, PARTY, ITEM, RUN}

var selected_slot: Vector2 = Vector2(0,0)
var v2_to_slot: Dictionary = {
	Vector2(0,0): MoveSlot.FIGHT,
	Vector2(1,0): MoveSlot.PARTY,
	Vector2(0,1): MoveSlot.ITEM,
	Vector2(1,1): MoveSlot.RUN }
	
@onready var slot: Dictionary = {
	MoveSlot.FIGHT: $Slot0/Background,
	MoveSlot.PARTY: $Slot1/Background,
	MoveSlot.ITEM: $Slot2/Background,
	MoveSlot.RUN: $Slot3/Background }
	
func _ready() -> void:
	set_active_slot()
	
func _input(event: InputEvent) -> void:
	if not processing or BattleManager.processing_turn:
		return
	if event.is_action_pressed("yes"):
		_input_selection()
	if event.is_action_pressed("no"):
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
	
func _input_selection():
	if not processing or BattleManager.processing_turn:
		return
	match get_curr_slot():
		MoveSlot.FIGHT:
			print("FIGHT")
			UiManager.push_ui(UiManager.battle_moves_scene)
		MoveSlot.PARTY:
			print("PARTY")
			PartyManager.show_party()
		MoveSlot.ITEM: print("ITEM")
		MoveSlot.RUN: print("RUN")
	
func get_curr_slot():
	return v2_to_slot[selected_slot]
	
func unset_active_slot():
	slot[get_curr_slot()].frame = 0
	
func set_active_slot():
	slot[get_curr_slot()].frame = 1
	
func _on_party_closed():
	processing = true
