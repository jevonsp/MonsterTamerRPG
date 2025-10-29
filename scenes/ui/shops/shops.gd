extends CanvasLayer

const VISIBLE_SLOTS: int = 6
const TILE_WIDTH: int = 160

enum Slot {SLOT0, SLOT1, SLOT2, SLOT3, SLOT4, SLOT5}
var cursor_index: Slot = Slot.SLOT0

enum OptSlot {SLOT0, SLOT1, SLOT2}
var opt_hovered: OptSlot = OptSlot.SLOT0

enum State {OPTIONS, BUYING, SELLING}
var state: State = State.OPTIONS

var deciding: bool:
	set(value):
		deciding = value
		if value == true:
			options.visible = false
			unset_active_opt_slot()
			opt_hovered = OptSlot.SLOT0
			set_active_opt_slot()
		else:
			options.visible = true

@export var options: VBoxContainer

var viewport_start: int = 0
var items: Array[ItemSlot] = []
var player_items

@onready var slot: Dictionary = {
	Slot.SLOT0: $Items/Slot0,
	Slot.SLOT1: $Items/Slot1,
	Slot.SLOT2: $Items/Slot2,
	Slot.SLOT3: $Items/Slot3,
	Slot.SLOT4: $Items/Slot4,
	Slot.SLOT5: $Items/Slot5 }
@onready var slot_dict: Dictionary = {
	0: Slot.SLOT0,
	1: Slot.SLOT1,
	2: Slot.SLOT2,
	3: Slot.SLOT3,
	4: Slot.SLOT4,
	5: Slot.SLOT5 }
	
@onready var options_slot: Dictionary = {
	OptSlot.SLOT0: $Options/Slot0,
	OptSlot.SLOT1: $Options/Slot1,
	OptSlot.SLOT2: $Options/Slot2}

func _ready() -> void:
	if UiManager.ui_stack.is_empty():
		UiManager.ui_stack.append(self)
		set_active_opt_slot()
		
func set_inventory(item_array: Array[ItemSlot]):
	items = item_array
	for item in items:
		print(items)
		
	update_display()
	set_active_opt_slot()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("yes") \
	or event.is_action_pressed("no") or \
	event.is_action_pressed("up") or \
	event.is_action_pressed("down"):
		get_viewport().set_input_as_handled()
	
	if self != UiManager.ui_stack.back():
		return
	if event.is_action_pressed("yes"):
		match state:
			State.OPTIONS:
				choose_option()
			State.BUYING:
				if deciding:
					deciding = false
				else:
					choose_option_buying()
			State.SELLING:
				if deciding:
					deciding = false
				else:
					choose_option_selling()
	if event.is_action_pressed("no"):
		match state:
			State.OPTIONS:
				close()
			State.BUYING:
				deciding = false
				_set_state(State.OPTIONS)
				unset_active_slot()
			State.SELLING:
				deciding = false
				_set_state(State.OPTIONS)
				unset_active_slot()
	if event.is_action_pressed("up"):
		print("deciding: ", deciding)
		if deciding:
			match state:
				State.BUYING: _move(-1)
				State.SELLING: _move_selling(-1)
		else:
			_move_options(-1)
	if event.is_action_pressed("down"):
		print("deciding: ", deciding)
		if deciding:
			match state:
				State.BUYING: _move(1)
				State.SELLING: _move_selling(1)
		else:
			_move_options(1)
	
func _move(direction: int):
	if items.size() == 0:
		return
	print("direction: ", direction)
	unset_active_slot()
	var old_cursor = cursor_index
	var old_viewport = viewport_start
	cursor_index = clamp(cursor_index + direction, 0, items.size())
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
	
	var max_viewport = max(0, items.size() - VISIBLE_SLOTS)
	viewport_start = clamp(viewport_start, 0, max_viewport)
	print("viewport_start after: ", viewport_start)
	
	if viewport_start != old_viewport:
		update_display()
		set_active_slot()
	else:
		set_active_slot()
	
	set_active_slot()
	
func _move_selling(direction: int):
	if player_items.size() == 0:
		return
	print("direction: ", direction)
	unset_active_slot()
	var old_cursor = cursor_index
	var old_viewport = viewport_start
	cursor_index = clamp(cursor_index + direction, 0, player_items.size())
	print("cursor_index: ", cursor_index)
	if cursor_index == player_items.size():
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
	
	var max_viewport = max(0, player_items.size() - VISIBLE_SLOTS)
	viewport_start = clamp(viewport_start, 0, max_viewport)
	print("viewport_start after: ", viewport_start)
	
	if viewport_start != old_viewport:
		update_display()
		set_active_slot()
	else:
		set_active_slot()
	
	set_active_slot()
	
func _move_options(direction: int):
	print("move_options called")
	unset_active_opt_slot()
	opt_hovered = (opt_hovered + direction) % OptSlot.size() as OptSlot
	if opt_hovered < 0: opt_hovered = (OptSlot.size() - 1) as OptSlot
	set_active_opt_slot()
			
func choose_option():
	match opt_hovered:
		0: 
			deciding = true
			_set_state(State.BUYING)
			set_active_slot()
		1: 
			deciding = true
			_set_state(State.SELLING)
			set_active_slot()
		2: 
			close()
		
func choose_option_buying():
	match opt_hovered:
		0: buy()
		1: print(opt_hovered)
		2: 
			print("called")
			print("deciding: ", deciding)
			deciding = true
	
func choose_option_selling():
	match opt_hovered:
		0: sell()
		1: print(opt_hovered)
		2: 
			print("called")
			print("deciding: ", deciding)
			deciding = true
		
func _set_state(new_state):
	if new_state == state:
		return
	state = new_state
	match new_state:
		State.OPTIONS:
			update_display()
			options_slot[0].get_node("Label").text = "Buy"
			options_slot[1].get_node("Label").text = "Sell"
			options_slot[2].get_node("Label").text = "Cancel"
		State.BUYING:
			options_slot[0].get_node("Label").text ="Buy 1"
			options_slot[1].get_node("Label").text ="Buy X"
			options_slot[2].get_node("Label").text ="Cancel"
		State.SELLING:
			update_display_selling()
			options_slot[0].get_node("Label").text ="Sell 1"
			options_slot[1].get_node("Label").text ="Sell X"
			options_slot[2].get_node("Label").text ="Cancel"
		
func buy(amount: int = 1):
	print("buy %s %s" % [amount, items[cursor_index]["item"].name])
	InventoryManager.add_items(items[cursor_index]["item"], amount)
	print(InventoryManager.inventory)
	update_display()
	
func sell(amount: int = 1):
	var item = player_items[cursor_index] as Item
	print("sell %s %s" % [amount, item["item"].name])
	if item.key_item:
		DialogueManager.show_dialogue("Thats too important to sell!")
		await DialogueManager.dialogue_closed
	if amount > item["quantity"]:
		DialogueManager.show_dialogue("Not enough to sell that many!")
		await DialogueManager.dialogue_closed
	
	InventoryManager.remove_items(item["item"], amount)
	update_display_selling()
			
func close():
	UiManager.pop_ui(self)
	
func update_display():
	for i in range(VISIBLE_SLOTS):
		var slot_enum = Slot.values()[i]
		var data_index = viewport_start + i
		
		if data_index < items.size():
			var item_slot = items[data_index]
			update_slot(item_slot, slot_enum)
		else:
			clear_slot(slot_enum)

func update_slot(item_slot: ItemSlot, slot_enum: Slot) -> void:
	var slot_node = slot[slot_enum]
	slot_node.modulate = Color(1, 1, 1, 1)
	
	var icon = slot_node.get_node_or_null("Icon")
	if icon:
		icon.texture = item_slot.item.icon
	
	var name_label = slot_node.get_node_or_null("NameLabel")
	if name_label:
		name_label.text = item_slot.item.name
	
	var quant_label = slot_node.get_node_or_null("QuantityLabel")
	if quant_label:
		if item_slot.infinite:
			quant_label.text = "-"
		else:
			quant_label.text = "x" + str(item_slot.quantity)
	
	var desc_label = slot_node.get_node_or_null("DescriptionLabel")
	if desc_label:
		desc_label.text = item_slot.item.short_description

func clear_slot(slot_enum: Slot) -> void:
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
		
func update_display_selling():
	player_items = InventoryManager.inventory
	print("player_items:", player_items)
	
	print("update displays here")
	for i in range(VISIBLE_SLOTS):
		var slot_enum = Slot.values()[i]
		var data_index = viewport_start + i
		if data_index < player_items.size():
			var item_index = player_items[data_index]
			print("item_index: ", item_index)
			var item = item_index["item"]
			var quant = item_index["quantity"]
			print("item: ", item.name)
			update_slot_selling(item, quant, slot_enum)
		else:
			clear_slot_selling(slot_enum)
	
func update_slot_selling(item: Item, quant: int, slot_enum: int) -> void:
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
	
func clear_slot_selling(slot_enum: int) -> void:
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
		
func get_ui_slot():
	var ui_index = cursor_index - viewport_start
	return slot_dict[ui_index]
	
func unset_active_slot():
	slot[get_ui_slot()].region_rect.position.x = 0
	
func set_active_slot():
	slot[get_ui_slot()].region_rect.position.x = TILE_WIDTH
	
func unset_active_opt_slot():
	options_slot[opt_hovered].region_rect.position.x = 0
	
func set_active_opt_slot():
	options_slot[opt_hovered].region_rect.position.x = TILE_WIDTH
	
