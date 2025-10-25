extends CanvasLayer

const VISIBLE_SLOTS = 6

var processing: bool = false
var reordering: bool = false
var swap_index: int = -1

enum Slot {SLOT0, SLOT1, SLOT2, SLOT3, SLOT4, SLOT5}
var cursor_index: Slot = Slot.SLOT0
var viewport_start: int = 0
var items: Array[Dictionary] = []

@onready var slot: Dictionary = {
	Slot.SLOT0: $Slot0/Background,
	Slot.SLOT1: $Slot1/Background,
	Slot.SLOT2: $Slot2/Background,
	Slot.SLOT3: $Slot3/Background,
	Slot.SLOT4: $Slot4/Background,
	Slot.SLOT5: $Slot5/Background }
@onready var slot_dict: Dictionary = {
	0: Slot.SLOT0,
	1: Slot.SLOT1,
	2: Slot.SLOT2,
	3: Slot.SLOT3,
	4: Slot.SLOT4,
	5: Slot.SLOT5 }

func _ready() -> void:
	add_to_group("inventory")
	if UiManager.ui_stack.is_empty():
		UiManager.ui_stack.append(self)
	set_active_slot()
	processing = true
	items = InventoryManager.inventory
	update_display()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("yes") \
	or event.is_action_pressed("no") or \
	event.is_action_pressed("up") or \
	event.is_action_pressed("down"):
		get_viewport().set_input_as_handled()
	
	if self != UiManager.ui_stack.back():
		return
	
	if event.is_action_pressed("yes"):
		if not reordering:
			if cursor_index < InventoryManager.inventory.size():
				_open_options()
		elif reordering:
			swap_items(swap_index, cursor_index)
			reordering = false
			swap_index = -1
			set_active_slot()
	if event.is_action_pressed("no"):
		if not reordering:
			close()
		else:
			cancel_swap()
			
	if event.is_action_pressed("up"):
		_move(-1)
	if event.is_action_pressed("down"):
		_move(1)
	
func _move(direction: int):
	if InventoryManager.inventory.size() == 0:
		return
	print("direction: ", direction)
	unset_active_slot()
	var old_cursor = cursor_index
	var old_viewport = viewport_start
	cursor_index = clamp(cursor_index + direction, 0, InventoryManager.inventory.size() - 1)
	print("cursor_index: ", cursor_index)
	if cursor_index == items.size():
		cursor_index = old_cursor
		print("returning to old cursor_index: ", cursor_index)
		set_active_slot()
		return
	if cursor_index == old_cursor:
		set_active_slot()
		return
	var relative_cursor_pos = cursor_index - viewport_start
	print("viewport_start: ", viewport_start)
	if relative_cursor_pos >= VISIBLE_SLOTS:
		viewport_start = cursor_index - VISIBLE_SLOTS + 1
	elif relative_cursor_pos < 0:
		viewport_start = cursor_index
	print("cursor_index after: ", cursor_index)
	
	var max_viewport = max(0, InventoryManager.inventory.size() - VISIBLE_SLOTS)
	viewport_start = clamp(viewport_start, 0, max_viewport)
	print("viewport_start after: ", viewport_start)
	
	if viewport_start != old_viewport:
		update_display()
		set_active_slot()
	else:
		set_active_slot()
	
	if not reordering:
		set_active_slot()
	else:
		set_moving_slot()
	
func get_ui_slot():
	var ui_index = cursor_index - viewport_start
	return slot_dict[ui_index]
	
func unset_active_slot():
	slot[get_ui_slot()].frame = 0
	
func set_active_slot():
	slot[get_ui_slot()].frame = 1
	
func set_moving_slot():
	slot[get_ui_slot()].frame = 2
	
func close():
	UiManager.pop_ui(self)
	UiManager.context = ""
	
func swap_items(from_index: int, to_index: int) -> void:
	if from_index == to_index:
		cancel_swap()
		return
	InventoryManager.swap_items(from_index, to_index)
	update_display()
	
func cancel_swap():
	print("cancelling swap")
	reordering = false
	set_active_slot()
	
func update_display():
	items = InventoryManager.inventory
	
	print("update displays here")
	for i in range(VISIBLE_SLOTS):
		var slot_enum = Slot.values()[i]
		var data_index = viewport_start + i
		if data_index < items.size():
			var item_index = items[data_index]
			print("item_index: ", item_index)
			var item = item_index["item"]
			var quant = item_index["quantity"]
			print("item: ", item.name)
			update_slot(item, quant, slot_enum)
		else:
			clear_slot_ui(slot_enum)
	
func update_slot(item: Item, quant: int, slot_enum: int) -> void:
	var slot_node = slot[slot_enum]
	slot_node.modulate = Color(1, 1, 1, 1)
	var icon = slot_node.get_node_or_null("Icon")
	if icon:
		icon.texture = item.icon
	var name_label = slot_node.get_node_or_null("NameLabel")
	if name_label:
		name_label.text = item.name
	var quant_label = slot_node.get_node_or_null("QuantityLabel")
	if quant_label:
		quant_label.text = "x: " + str(quant)
	var desc_label = slot_node.get_node_or_null("DescriptionLabel")
	if desc_label:
		desc_label.text = item.short_description
	
func clear_slot_ui(slot_enum: int) -> void:
	var slot_node = slot[slot_enum]
	slot_node.modulate = Color(0.5, 0.5, 0.5, 0.6)
	var icon = slot_node.get_node_or_null("Icon")
	if icon:
		icon.texture = null
	var name_label = slot_node.get_node_or_null("NameLabel")
	if name_label:
		name_label.text = ""
	var quant_label = slot_node.get_node_or_null("QuantityLabel")
	if quant_label:
		quant_label.text = ""
	var desc_label = slot_node.get_node_or_null("DescriptionLabel")
	if desc_label:
		desc_label.text = ""
		
func _open_options():
	var options = UiManager.push_ui(UiManager.inventory_options_scene)
	if not options.option_chosen.is_connected(_on_option_chosen):
		options.option_chosen.connect(_on_option_chosen)
	print("inventory opening options context: ", UiManager.context)
	if UiManager.context == "from_party":
		options.set_limited_options(true)
	
func _on_option_chosen(slot_enum: int):
	var item = items[cursor_index]["item"]
	
	match slot_enum:
		0:
			if item.is_held:
				DialogueManager.show_dialogue("That cant be held!")
				await DialogueManager.dialogue_closed
				return
			if item.in_battle_only and not BattleManager.in_battle:
				DialogueManager.show_dialogue("You arent in battle right now")
				await DialogueManager.dialogue_closed
				return
			if item.effects.is_empty():
				DialogueManager.show_dialogue("This item has no use!")
				await DialogueManager.dialogue_closed
				return
		1:
			if not item.is_held:
				DialogueManager.show_dialogue("That isn't a held item!")
				await DialogueManager.dialogue_closed
				return
		2: 
			reordering = true
			swap_index = cursor_index
			set_moving_slot()
			return
		3: 
			return
	print("got slot_enum: " , slot_enum)
	print("inventory got UiManager.context: ", UiManager.context)
	match UiManager.context:
		"":
			print("normal case where transitions to party")
			UiManager.context = "picking"
			UiManager.push_ui_by_name(UiManager.SCENE_PARTY)
			EventBus.item_chosen.emit(item)
		"using":
			print("use: ", item.name)
			EventBus.using_item.emit(item)
			update_display()
			close()
			return
		"giving":
			print("give: ", item.name)
			EventBus.giving_item.emit(item)
			update_display()
			close()
			return
		_:
			print("wrong ui context")
