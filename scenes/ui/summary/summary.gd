extends CanvasLayer

@export var portrait: TextureRect
@export var hp_bar: TextureProgressBar
@export var exp_bar: TextureProgressBar
@export var name_label: Label
@export var level_label: Label
@export var type_label: Label
@export var role_label: Label

@export var hp_label: Label
@export var speed_label: Label
@export var attack_label: Label
@export var defense_label: Label
@export var special_attack_label: Label
@export var special_defense_label: Label

@export var description_pane: Sprite2D

enum State {DEFAULT, READING, REORDERING}
var state: State = State.DEFAULT
var moving_index: int = -1

var selected_monster: int = 0

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
	if UiManager.ui_stack.is_empty():
		UiManager.ui_stack.append(self)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("yes") \
	or event.is_action_pressed("no") or \
	event.is_action_pressed("up") or \
	event.is_action_pressed("down"):
		get_viewport().set_input_as_handled()
	if self != UiManager.ui_stack.back():
		return
	match state:
		State.DEFAULT:
			if event.is_action_pressed("yes"):
				_set_state(State.READING)
			if event.is_action_pressed("no"):
				close()
			if event.is_action_pressed("left"):
				print("starting at slot: ", selected_monster)
				_shift(-1)
				print("ending at slot:" , selected_monster)
				display_selected_monster()
			if event.is_action_pressed("right"):
				print("starting at slot: ", selected_monster)
				_shift(1)
				print("ending at slot:" , selected_monster)
				display_selected_monster()
		State.READING:
			if event.is_action_pressed("yes"):
				_set_state(State.REORDERING)
				moving_index = selected_slot
				print(moving_index)
			if event.is_action_pressed("no"):
				_set_state(State.DEFAULT)
			if event.is_action_pressed("up"):
				_move(-1)
			if event.is_action_pressed("down"):
				_move(1)
		State.REORDERING:
			if event.is_action_pressed("yes"):
				print("move %s to %s" % [moving_index, selected_slot])
				moving_index = -1
				_set_state(State.READING)
			if event.is_action_pressed("no"):
				_set_state(State.DEFAULT)
			if event.is_action_pressed("up"):
				_move(-1)
			if event.is_action_pressed("down"):
				_move(1)
				
func _move(direction: int):
	unset_active_slot()
	selected_slot = (selected_slot + direction) % PartyManager.party[selected_monster].moves.size() as Slot
	if selected_slot < 0: selected_slot = (PartyManager.party[selected_monster].moves.size() - 1) as Slot
	match state:
		State.READING:
			set_active_slot()
		State.REORDERING:
			set_moving_slot()
	display_move_description()
	
func _shift(direction: int):
	selected_monster = (selected_monster + direction) % PartyManager.party.size()
	if selected_monster < 0: selected_monster = (PartyManager.party.size() - 1)
	
func _set_state(new_state: State) -> void:
	if new_state == state:
		return
	state = new_state
	match state:
		State.DEFAULT:
			description_pane.visible = false
			moving_index = -1
			unset_active_slot()
		State.READING:
			description_pane.visible = true
			set_active_slot()
			display_move_description()
		State.REORDERING:
			set_moving_slot()
			
func unset_active_slot():
	slot[selected_slot].frame = 0
	
func set_active_slot():
	slot[selected_slot].frame = 1
	
func set_moving_slot():
	slot[selected_slot].frame = 2
	
func close():
	selected_monster = 0
	UiManager.pop_ui(self)
	
func display_selected_monster():
	var monster = PartyManager.party[selected_monster]
	print(monster.name)
	portrait.texture = monster.species.sprite
	
	hp_bar.max_value = monster.max_hitpoints
	hp_bar.value = monster.hitpoints
	hp_bar.min_value = 0
	
	var next_value = monster.experience_to_level(monster.level + 1)
	var current_value = monster.experience_to_level(monster.level)
	exp_bar.max_value = next_value
	exp_bar.value = monster.experience - current_value
	exp_bar.min_value = 0
	
	name_label.text = monster.name
	
	level_label.text = "Lvl. " + str(monster.level)
	
	type_label.text = monster.type
	
	role_label.text = monster.role
	
	hp_label.text = "HITPOINTS: " + str(monster.max_hitpoints)
	speed_label.text = "SPEED: " + str(monster.speed)
	attack_label.text = "ATTACK: " + str(monster.attack)
	defense_label.text = "DEFENSE: " + str(monster.defense)
	special_attack_label.text = "SPECIAL ATTACK: " + str(monster.special_attack)
	special_defense_label.text = "SPECIAL DEFENSE: " + str(monster.special_defense)
	
	display_moves()
	
func display_moves():
	var monster = PartyManager.party[selected_monster]
	for i in range(4):
		var slot_node = get_node("Slot%d" % i).get_child(0)
		print(slot_node)
		print(slot_node.get_children())
		if i < monster.moves.size():
			slot_node.get_node("Name").text = monster.moves[i].name
			slot_node.get_node("Power").text = str(get_move_power(monster.moves[i]))
			slot_node.get_node("Type").text = str(monster.moves[i].type)
		else:
			slot_node.get_node("Name").text = ""
			slot_node.get_node("Power").text = ""
			slot_node.get_node("Type").text = ""
			
func get_move_power(move: Move) -> String:
	for effect in move.effects:
		if effect.name == "DAMAGE":
			return str (effect.base_power)
	return "-"
			
func display_move_description():
	pass
	
