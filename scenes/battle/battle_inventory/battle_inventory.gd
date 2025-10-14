extends CanvasLayer

signal monster_picked

@export var container: HBoxContainer
@export var picker: HBoxContainer

var monster_chosen

func _ready() -> void:
	for i in range(picker.get_child_count()):
		var button = picker.get_child(i)
		button.pressed.connect(use_item.bind(i))

func display_inventory():
	var inventory = InventoryManager.inventory
	for i in inventory.size():
		var item = inventory[i]["item"]
		var button = Button.new()
		button.text = "%s x%d" % [inventory[i]["item"].name, inventory[i]["quantity"]]
		button.pressed.connect(on_item_clicked.bind(item))
		container.add_child(button)

func on_item_clicked(item: Item):
	print("item:", item.name)
	if item.target_type == "ALLY":
		picker_visibility(true)
		await monster_picked
		if monster_picked == null:
			return
		print("monster_chosen: ", monster_chosen)
		var action = ItemAction.new(BattleManager.player_actor, [monster_chosen], item)
		BattleManager.on_action_selected(action)
	elif item.target_type == "ENEMY":
		var action
		if BattleManager.single_battle:
			action = ItemAction.new(BattleManager.player_actor, [BattleManager.enemy_actor], item)
		else:
			print("double catch not implemented going default")
			action = ItemAction.new(BattleManager.player_actor, [BattleManager.enemy_actor], item)
		BattleManager.on_action_selected(action)
	close()
	
func use_item(slot_index: int):
	if slot_index < PartyManager.party.size():
		var party_monster = PartyManager.party[slot_index]
		monster_chosen = party_monster
		monster_picked.emit()
	else:
		monster_chosen = null
		monster_picked.emit()
	
func picker_visibility(b: bool) -> void:
	picker.visible = b
	
func close():
	queue_free()
