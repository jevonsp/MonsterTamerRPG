extends CanvasLayer

const HP_SCALE: float = 10.0

var reordering: bool = false

@export var testing: bool = true

var processing: bool = true
var swap_index: int = -1
var free_switch: bool = false

var chosen_item: Item = null

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

var portrait_map: Dictionary = {}
var hp_map: Dictionary = {}
var exp_map: Dictionary = {}
var name_map: Dictionary = {}
var level_map: Dictionary = {}
var type_map: Dictionary = {}
var role_map: Dictionary = {}

func _ready() -> void:
	print("Party scene _ready() called")
	print("PartyManager exists: ", PartyManager != null)
	if UiManager.ui_stack.is_empty():
		UiManager.ui_stack.append(self)

	EventBus.free_switch.connect(_on_free_switch)
	EventBus.using_item.connect(use_item)
	EventBus.giving_item.connect(give_item)
	EventBus.item_chosen.connect(_on_item_chosen)
	EventBus.health_changed.connect(_on_health_changed)
	
	if not BattleManager.in_battle:
		free_switch = true
	set_active_slot()
	update_slots()
	
#region Movement and Inputs
func _input(event: InputEvent) -> void:
	if not processing:
		return
	
	if event.is_action_pressed("yes") \
	or event.is_action_pressed("no") or \
	event.is_action_pressed("up") or \
	event.is_action_pressed("down"):
		get_viewport().set_input_as_handled()
		
	if self != UiManager.ui_stack.back():
		return
	
	if event.is_action_pressed("yes"):
		if reordering:
			swap_monsters(swap_index, v2_to_slot[selected_slot])
			set_active_slot()
			reordering = false
			return
		match UiManager.context:
			"picking":
				print("context:  picking")
				await use_item(chosen_item)
				chosen_item = null
				UiManager.context = ""
				close()
			"using":
				print("context: using")
				return
			"giving":
				print("context: giving")
				return
			"":
				if v2_to_slot[selected_slot] < PartyManager.party.size():
					_open_options()
				
	if event.is_action_pressed("no"):
		if reordering:
			set_active_slot()
			reordering = false
			return
		elif not reordering:
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
	if not reordering:
		set_active_slot()
	else:
		set_moving_slot()
	
func get_allowed_slots() -> Array:
	var left = [Vector2(0, 0)]
	var right: Array = []
	var party_size = 6 if testing else PartyManager.party.size()
	var right_slots = party_size - 1
	for i in range(right_slots):
		right.append(Vector2(1, i))
		
	return left + right
	
func _open_options():
	var options = UiManager.push_ui(UiManager.party_options_scene)
	if not options.option_chosen.is_connected(_on_option_chosen):
		options.option_chosen.connect(_on_option_chosen)
	
func _on_option_chosen(slot_enum) -> void:
	print("option chosen")
	match slot_enum:
		0: 
			var summary = UiManager.push_ui(UiManager.summary_scene)
			summary.selected_monster = v2_to_slot[selected_slot]
			print("selected slot: ", v2_to_slot[selected_slot])
			summary.display_selected_monster()
		1:
			if PartyManager.party.size() == 1:
				return
			initiate_swap(v2_to_slot[selected_slot])
		2: 
			print("item")
			open_inventory()
		3: print("options closed")
	
func get_curr_slot():
	return v2_to_slot[selected_slot]
	
func unset_active_slot():
	slot[get_curr_slot()].frame = 0
	
func set_active_slot():
	slot[get_curr_slot()].frame = 1
	
func set_moving_slot():
	slot[get_curr_slot()].frame = 2
	
func close():
	clear_maps()
	UiManager.pop_ui(self)
	UiManager.context = ""
#endregion

#region Mapping
func update_slots():
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
			update_maps(monster, slot_enum)
		else:
			slot_node.modulate = Color(0.5, 0.5, 0.5, 0.6)
			clear_slot_ui(slot_enum)
	
func update_maps(monster: Monster, slot_enum: int) -> void:
	print("updating slot: ", slot_enum, " with monster: ", monster)
	map_portrait(monster, slot_enum)
	map_hp(monster, slot_enum)
	map_exp(monster, slot_enum)
	map_name(monster, slot_enum)
	map_level(monster, slot_enum)
	map_type(monster, slot_enum)
	map_role(monster, slot_enum)
	
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
			
func clear_maps():
	for map in [portrait_map, hp_map, exp_map, name_map, level_map, type_map, role_map]:
		map.clear()
#endregion
	
#region Mapping Helpers
func map_portrait(monster: Monster, slot_enum: int):
	var portrait_node = slot[slot_enum].get_node_or_null("Portrait")
	if portrait_node:
		portrait_node.texture = monster.species.sprite
		portrait_map[monster] = portrait_node
func map_hp(monster: Monster, slot_enum: int):
	var hp_node = slot[slot_enum].get_node_or_null("PlayerHP")
	if hp_node:
		hp_node.max_value = monster.max_hitpoints * HP_SCALE
		hp_node.value = monster.hitpoints * HP_SCALE
		hp_map[monster] = hp_node
func map_name(monster: Monster, slot_enum: int):
	var name_node = slot[slot_enum].get_node_or_null("NameLabel")
	if name_node:
		name_node.text = monster.name
		name_map[monster] = name_node
func map_exp(monster: Monster, slot_enum: int):
	var exp_node = slot[slot_enum].get_node_or_null("PlayerEXP")
	if exp_node:
		var next_level_req = monster.experience_to_level(monster.level + 1)
		var current = monster.experience - monster.experience_to_level(monster.level)
		exp_node.max_value = next_level_req
		exp_node.value = current
		exp_map[monster] = exp_node
func map_level(monster: Monster, slot_enum: int):
	var level_node = slot[slot_enum].get_node_or_null("LevelLabel")
	if level_node:
		level_node.text = "Lvl. " + str(monster.level)
		level_map[monster] = level_node
func map_type(monster: Monster, slot_enum: int):
	var type_node = slot[slot_enum].get_node_or_null("TypeLabel")
	if type_node:
		type_node.text = "Type: " + monster.type
		type_map[monster] = type_node
func map_role(monster: Monster, slot_enum: int):
	var role_node = slot[slot_enum].get_node_or_null("RoleLabel")
	if role_node:
		role_node.text = "Role: " + monster.role
		role_map[monster] = role_node
#endregion

func initiate_swap(party_index):
	if BattleManager.in_battle:
		if party_index == 0:
			cancel_swap()
			DialogueManager.show_dialogue("You cant swap in a monster already fighting")
			return
		print("initiating battle swap")
		swap_monsters(party_index, 0)
	else:
		print("initiating swap")
		reordering = true
		swap_index = v2_to_slot[selected_slot]
		set_moving_slot()
	
func cancel_swap():
	print("cancelling swap")
	reordering = false
	swap_index = -1
	set_active_slot()
	
func _on_free_switch() -> void: free_switch = true
	
func swap_monsters(from_index: int, to_index: int):
	print("from_index: ", from_index, ", to_index: ", to_index)
	if from_index == to_index:
		cancel_swap()
		return
	if not BattleManager.in_battle:
		PartyManager.swap_party(from_index, to_index, free_switch)
		update_slots()
		swap_index = -1
		set_active_slot()
		return
	else:
		var monster = PartyManager.party[from_index]
		if monster.is_fainted:
			print("monster cannot fight")
			return
		else:
			print("creating switch action")
			PartyManager.swap_party(from_index, to_index, free_switch)
			free_switch = false
			close()
			
func open_inventory():
	print("attempt to call: push_ui_by_name")
	UiManager.context = "from_party"
	UiManager.push_ui_by_name(UiManager.SCENE_INVENTORY)
	
func use_item(item: Item) -> void:
	print("party got UiManager.context: ", UiManager.context)
	var slot_enum = v2_to_slot[selected_slot]
	print("would use item on: ", slot_enum)
	for effect in item.effects:
		effect.apply(PartyManager.party[slot_enum], PartyManager.party[slot_enum], item)
		print("effect: ", effect)
	processing = false
	print("processing: ", processing)
	await EventBus.party_effect_ended
	InventoryManager.remove_items(item)
	processing = true
	print("processing: ", processing)
	
func give_item(item) -> void:
	var slot_enum = v2_to_slot[selected_slot]
	print("would give item to: ", slot_enum)
	PartyManager.party[slot_enum].held_item = item
	InventoryManager.remove_items(item)
	DialogueManager.show_dialogue("Gave %s to %s to hold" % [item.name, PartyManager.party[slot_enum].name])
	await DialogueManager.dialogue_closed
	
func _on_item_chosen(item: Item) -> void:
	chosen_item = item
	
func _on_health_changed(monster: Monster, _old: int, new: int) -> void:
	print("_on_health_changed called")
	var tween = get_tree().create_tween()
	tween.tween_property(hp_map[monster], "value", new * HP_SCALE, Settings.game_speed)
	await tween.finished
	EventBus.health_done_animating.emit()
	print("health_done_animating")
	processing = true
	print("processing: ", processing)
	
