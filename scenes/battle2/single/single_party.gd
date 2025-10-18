extends CanvasLayer

@export var processing: bool = false

#region Slot
enum PartySlot {SLOT0, SLOT1, SLOT2, SLOT3, SLOT4, SLOT5}
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
#endregion

#region Slot Maps
var portrait_map: Dictionary = {}
var hp_map: Dictionary = {}
var exp_map: Dictionary = {}
var name_map: Dictionary = {}
var level_map: Dictionary = {}
var type_map: Dictionary = {}
var role_map: Dictionary = {}

@onready var slot0_portrait = $Slot0/Background/Portrait
@onready var slot0_hp = $Slot0/Background/PlayerHP
@onready var slot0_exp = $Slot0/Background/PlayerEXP
@onready var slot0_name = $Slot0/Background/NameLabel
@onready var slot0_level = $Slot0/Background/LevelLabel
@onready var slot0_type = $Slot0/Background/TypeLabel
@onready var slot0_role = $Slot0/Background/RoleLabel

@onready var slot1_portrait = $Slot1/Background/Portrait
@onready var slot1_hp = $Slot1/Background/PlayerHP
@onready var slot1_exp = $Slot1/Background/PlayerEXP
@onready var slot1_name = $Slot1/Background/NameLabel
@onready var slot1_level = $Slot1/Background/LevelLabel
@onready var slot1_type = $Slot1/Background/TypeLabel
@onready var slot1_role = $Slot1/Background/RoleLabel

@onready var slot2_portrait = $Slot2/Background/Portrait
@onready var slot2_hp = $Slot2/Background/PlayerHP
@onready var slot2_exp = $Slot2/Background/PlayerEXP
@onready var slot2_name = $Slot2/Background/NameLabel
@onready var slot2_level = $Slot2/Background/LevelLabel
@onready var slot2_type = $Slot2/Background/TypeLabel
@onready var slot2_role = $Slot2/Background/RoleLabel

@onready var slot3_portrait = $Slot3/Background/Portrait
@onready var slot3_hp = $Slot3/Background/PlayerHP
@onready var slot3_exp = $Slot3/Background/PlayerEXP
@onready var slot3_name = $Slot3/Background/NameLabel
@onready var slot3_level = $Slot3/Background/LevelLabel
@onready var slot3_type = $Slot3/Background/TypeLabel
@onready var slot3_role = $Slot3/Background/RoleLabel

@onready var slot4_portrait = $Slot4/Background/Portrait
@onready var slot4_hp = $Slot4/Background/PlayerHP
@onready var slot4_exp = $Slot4/Background/PlayerEXP
@onready var slot4_name = $Slot4/Background/NameLabel
@onready var slot4_level = $Slot4/Background/LevelLabel
@onready var slot4_type = $Slot4/Background/TypeLabel
@onready var slot4_role = $Slot4/Background/RoleLabel

@onready var slot5_portrait = $Slot5/Background/Portrait
@onready var slot5_hp = $Slot5/Background/PlayerHP
@onready var slot5_exp = $Slot5/Background/PlayerEXP
@onready var slot5_name = $Slot5/Background/NameLabel
@onready var slot5_level = $Slot5/Background/LevelLabel
@onready var slot5_type = $Slot5/Background/TypeLabel
@onready var slot5_role = $Slot5/Background/RoleLabel
#endregion

func _ready() -> void:
	EventBus.party_open.emit()
	processing = true
	set_active_slot()
	update_maps()
	
#region Movement and Inputs
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
	EventBus.party_closed.emit()
	clear_maps()
	get_parent().remove_child(self)
	queue_free()
#endregion

func update_maps():
	clear_maps()
	
	var party = PartyManager.party
	var party_size = party.size()
	var total_slots = PartySlot.values().size()
	
	for i in range(total_slots):
		var slot_enum = PartySlot.values()[i]
		var slot_node = slot[slot_enum]
		
		if i < party_size:
			var monster = party[i]
			slot_node.modulate = Color(1, 1, 1, 1)
			update_slot(monster, slot_enum)
		else:
			slot_node.modulate = Color(0.5, 0.5, 0.5, 0.6)
			clear_slot_ui(slot_enum)
	
func clear_maps():
	pass
	
func update_slot(_monster: Monster, _slot_enum: int) -> void:
	pass
	
func clear_slot_ui(slot_enum: int) -> void:
	var slot_node = slot[slot_enum]
	var portrait = slot_node.get_node_or_null("Portrait")
	if portrait:
		portrait.texture = null
	var bars = ["PlayerHP", "PlayerEXP"]
	for bar_name in bars:
		var bar = slot_node.get_node_or_null(bar_name)
		if bar:
			bar.visible = false
	var labels = ["NameLabel", "LevelLabel", "TypeLabel", "RoleLabel"]
	for label_name in labels:
		var label = slot_node.get_node_or_null(label_name)
		if label:
			label.text = ""
	
#region Mapping Helpers
func map_portrait(_monster: Monster, _slot_enum: int):
	pass
func map_hp(_monster: Monster, _slot_enum: int):
	pass
func map_exp(_monster: Monster, _slot_enum: int):
	pass
func map_level(_monster: Monster, _slot_enum: int):
	pass
func map_type(_monster: Monster, _slot_enum: int):
	pass
func map_role(_monster: Monster, _slot_enum: int):
	pass
#endregion
