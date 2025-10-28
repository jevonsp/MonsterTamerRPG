extends CanvasLayer

const TILE_WIDTH: int = 160
const GRID_WIDTH = 6
const GRID_HEIGHT = 5
const BOX_SLOTS = GRID_HEIGHT * GRID_WIDTH

enum Slot { SLOT0, SLOT1, SLOT2, SLOT3, SLOT4, SLOT5, SLOT6, SLOT7, SLOT8, SLOT9,
			SLOT10, SLOT11, SLOT12, SLOT13, SLOT14, SLOT15, SLOT16, SLOT17, SLOT18, SLOT19,
			SLOT20, SLOT21, SLOT22, SLOT23, SLOT24, SLOT25, SLOT26, SLOT27, SLOT28, SLOT29 }

enum Box { BOX0, BOX1, BOX2, BOX3, BOX4, BOX5, BOX6, BOX7, BOX8, BOX9 }

@export var grid: GridContainer
@export var info: NinePatchRect
@export var party_popup: VBoxContainer

@export var name_label: Label
@export var portrait: TextureRect
@export var level_label: Label
@export var type_label: Label
@export var role_label: Label
@export var nature_label: Label

var selected_slot: Vector2 = Vector2(0,0)
var v2_to_slot: Dictionary = {}

var selected_box: int = 0

var selected_party_slot: int = 0

var reordering: bool = false
var monster_slot: int:
	get:
		return int(selected_box * (BOX_SLOTS)) + int(selected_slot.y * GRID_WIDTH + selected_slot.x)
var swap_index: int = -1

var depositing: bool:
	set(value):
		depositing = value
		if party_popup:
			party_popup.visible = value
		if info:
			info.visible = !value

@onready var slot: Dictionary = {}
@onready var party_slot: Dictionary = {}

var preload_monster

func _ready() -> void:
	if UiManager.ui_stack.is_empty():
		UiManager.ui_stack.append(self)
	
	# Build v2_to_slot dictionary
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var index = y * GRID_WIDTH + x
			v2_to_slot[Vector2(x, y)] = Slot.values()[index]

	# Build slot dictionary (assuming your nodes are named Slot0, Slot1, etc.)
	for i in range(GRID_WIDTH * GRID_HEIGHT):
		var slot_node = grid.get_node_or_null("Slot" + str(i))
		if slot_node:
			slot[Slot.values()[i]] = slot_node
			
	preload_monster = load("res://objects/monsters/pistol_shrimp/Pistol_Shrimp.tres")
			
	for i in range(0, 30):
		PartyManager.make_monster(preload_monster, 5)
		
	for i in range(0, 30):
		if PartyManager.storage[i] == null:
			continue
			
	party_popup.visible = false
			
	set_active_slot()
	display_mini_monsters()
	display_hovered_slot()
	
func _input(event: InputEvent) -> void:
	if self != UiManager.ui_stack.back():
		return
	
	if event.is_action_pressed("yes") \
	or event.is_action_pressed("no") or \
	event.is_action_pressed("up") or \
	event.is_action_pressed("down"):
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("up"):
		if depositing:
			_move_party(-1)
			return
		_move(Vector2.UP)
	if event.is_action_pressed("down"):
		if depositing:
			_move_party(1)
			return
		_move(Vector2.DOWN)
	if event.is_action_pressed("left"):
		if depositing:
			return
		if selected_slot.x == 0:
			_shift(-1)
		_move(Vector2.LEFT)
	if event.is_action_pressed("right"):
		if depositing:
			return
		if selected_slot.x == GRID_WIDTH - 1:
			_shift(1)
		_move(Vector2.RIGHT)
		
	if event.is_action_pressed("L"):
		_shift(-1)
	if event.is_action_pressed("R"):
		_shift(1)
		
	if event.is_action_pressed("yes"):
		if depositing:
			print("pressed yes while depositing")
			await PartyManager.deposit_monster(selected_party_slot)
			display_mini_monsters()
			selected_party_slot = 0
			depositing = false
			return
		if not reordering:
			_open_options()
		elif reordering:
			print("would swap %s with %s" % [swap_index, monster_slot])
			swap_slots()
			swap_index = -1
			reordering = false
			set_active_slot()
			
	if event.is_action_pressed("no"):
		if reordering:
			reordering = false
			swap_index = -1
			set_active_slot()
		if depositing:
			depositing = false
	
func _move(direction: Vector2):
	unset_active_slot()
	var new_slot = selected_slot + direction
	new_slot.x = clamp(new_slot.x, 0, GRID_WIDTH - 1)
	new_slot.y = clamp(new_slot.y, 0, GRID_HEIGHT - 1)
	selected_slot = new_slot

	if not reordering:
		set_active_slot()
	else:
		set_moving_slot()
	
	display_hovered_slot()
	
func _move_party(direction: int):
	party_unset_active_slot()
	selected_party_slot = (selected_party_slot + direction) % PartyManager.party.size()
	if selected_party_slot < 0: selected_party_slot = (PartyManager.party.size() - 1)
	party_set_active_slot()
	
func _shift(direction: int):
	selected_box = (selected_box + direction) % Box.size() as Box
	if selected_box < 0: selected_box = (Box.size() - 1) as Box
	display_mini_monsters()
	display_hovered_slot()
	
func get_curr_slot():
	return v2_to_slot[selected_slot]
	
func unset_active_slot():
	slot[get_curr_slot()].region_rect.position.x = 0
	
func set_active_slot():
	slot[get_curr_slot()].region_rect.position.x = TILE_WIDTH
	
func set_moving_slot():
	slot[get_curr_slot()].region_rect.position.x = TILE_WIDTH * 2
	
func party_unset_active_slot():
	party_slot[selected_party_slot].region_rect.position.x = 0
	
func party_set_active_slot():
	party_slot[selected_party_slot].region_rect.position.x = TILE_WIDTH
	
func _open_options():
	var options = UiManager.push_ui(UiManager.storage_options_scene)
	if not options.option_chosen.is_connected(_on_option_chosen):
		options.option_chosen.connect(_on_option_chosen)
		
func _on_option_chosen(slot_enum: int):
	match slot_enum:
		0: 
			swap_index = int(monster_slot)
			reordering = true
			set_moving_slot()
			print("swap_index: ", swap_index)
		1: 
			print("check party space")
			withdraw_monster()
		2: 
			print("open party to pick deposit")
			deposit_monster()
		3: 
			print("do release dialogue here")
		4: 
			pass
	
func display_hovered_slot():
	var monster = PartyManager.storage[monster_slot]
	if monster != null:
		print("display big %s in %s" % [monster.name, monster_slot % 30])
		name_label.text = monster.name
		portrait.texture = monster.species.sprite
		level_label.text = "Lvl. " + str(monster.level)
		type_label.text = monster.type
		role_label.text = monster.role
		nature_label.text = monster.NATURE_NAMES[monster.nature]
	else:
		display_empty_hovered_slot()
		
func display_empty_hovered_slot():
	print("nothing in %s" % [monster_slot % 30])
	name_label.text = ""
	portrait.texture = null
	level_label.text = ""
	type_label.text = ""
	role_label.text = ""
	nature_label.text = ""
	
func display_mini_monsters():
	var start_index: int = selected_box * (BOX_SLOTS)
	pass
	
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var slot_index = y * GRID_WIDTH + x
			var monster_index = start_index + slot_index
			var slot_node = slot[Slot.values()[slot_index]]
			var storage = PartyManager.storage
			if monster_index < storage.size() and storage[monster_index] != null:
				display_mini_slot(slot_node, storage[monster_index])
			else:
				display_empty_mini_slot(slot_node)
			
func display_mini_slot(slot_node: Node, monster: Monster):
	slot_node.get_node("MiniPortrait").texture = monster.species.sprite
	
func display_empty_mini_slot(slot_node: Node):
	slot_node.get_node("MiniPortrait").texture = null
	
func swap_slots():
	PartyManager.swap_storage(swap_index, monster_slot)
	display_mini_monsters()
	display_hovered_slot()
	
func withdraw_monster() -> void:
	if PartyManager.party.size() >= 6:
		DialogueManager.show_dialogue("No more room!")
		await DialogueManager.dialogue_closed
	else:
		await PartyManager.withdraw_monster(monster_slot)
		display_mini_monsters()
	
func deposit_monster() -> void:
	var null_count: int = 0
	for i in range(0, 300):
		if PartyManager.storage[i] == null:
			null_count += 1
	if null_count > 0:
		toggle_deposit_window(true)
		
func toggle_deposit_window(value: bool):
	print("open deposit window here")
	depositing = value
	display_party()
	party_set_active_slot()
	
func display_party() -> void:
	var party = PartyManager.party
	for i in range(6):
		var slot_node = party_popup.get_node_or_null("Slot" + str(i))
		if slot_node:
			party_slot[i] = slot_node
			if i < party.size() and party[i]:
				display_party_slot(slot_node, party[i])
			else:
				display_empty_party_slot(slot_node)
	
func display_party_slot(slot_node: Node, monster: Monster):
	if monster == null:
		display_empty_party_slot(slot_node)
		return
	else:
		slot_node.get_node("MiniPortrait").texture = monster.species.sprite
		slot_node.get_node("NameLabel").text = monster.name
		slot_node.get_node("LevelLabel").text = "Lvl. " + str(monster.level)
	
func display_empty_party_slot(slot_node: Node):
	slot_node.get_node("MiniPortrait").texture = null
	slot_node.get_node("NameLabel").text = ""
	slot_node.get_node("LevelLabel").text = ""
