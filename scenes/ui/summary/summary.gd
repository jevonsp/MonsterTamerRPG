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
@export var description_label: Label

enum State {DEFAULT, READING, REORDERING}
var state: State = State.DEFAULT
var moving_index: int = -1

var deciding: bool = false
var move_deciding: Move = null

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
				if not deciding:
					_set_state(State.REORDERING)
					moving_index = selected_slot
					print(moving_index)
				else:
					var monster = PartyManager.party[selected_monster]
					var selected_move = monster.moves[selected_slot]
					var decision = await DialogueManager.show_choice(
						"Are you sure you want to replace %s with %s" % [
							selected_move.name, move_deciding.name])
					if decision:
						print("yes: delete")
						monster.moves[selected_slot] = move_deciding
						display_moves()
						DialogueManager.show_dialogue("%s replaced %s with %s" % [
							monster.name, selected_move.name, move_deciding.name
						], true)
						await DialogueManager.dialogue_closed
						move_deciding = null
						close()
					else:
						print("no: restart")
					
			if event.is_action_pressed("no"):
				if not deciding:
					_set_state(State.DEFAULT)
				else:
					print("decide no here")
					var decision = await DialogueManager.show_choice(
						"Are you sure you want to stop learning %s" % move_deciding.name)
					if decision:
						print("yes: stop")
						var monster = PartyManager.party[selected_monster]
						DialogueManager.show_dialogue("%s did not learn %s" % [monster.name, move_deciding.name], true)
						await DialogueManager.dialogue_closed
						close()
					else:
						print("no: continue")
					
			if event.is_action_pressed("up"):
				_move(-1)
			if event.is_action_pressed("down"):
				_move(1)
		State.REORDERING:
			if event.is_action_pressed("yes"):
				var moves = PartyManager.party[selected_monster].moves
				var temp = moves[moving_index]
				moves[moving_index] = moves[selected_slot]
				moves[selected_slot] = temp
				moving_index = -1
				display_moves()
				display_move_description()
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
		if i < monster.moves.size():
			slot_node.get_node("Name").text = monster.moves[i].name
			slot_node.get_node("Power").text = (monster.moves[i]).get_move_power()
			slot_node.get_node("Type").text = str(monster.moves[i].type)
			slot_node.get_node("Category").text = (monster.moves[i]).get_move_damage_category()
		else:
			slot_node.get_node("Name").text = ""
			slot_node.get_node("Power").text = ""
			slot_node.get_node("Type").text = ""
			slot_node.get_node("Category").text = ""
	
func get_move_damage_category(move: Move) -> String:
	for effect in move.effects:
		if effect.name == "DAMAGE":
			return effect.damage_category
	return "-"
	
func display_move_description():
	var monster = PartyManager.party[selected_monster]
	var moves = monster.moves
	var description = moves[selected_slot].description
	description_label.text = description
	
