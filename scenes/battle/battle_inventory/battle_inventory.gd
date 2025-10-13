extends CanvasLayer

signal monster_picked

@export var container: HBoxContainer
@export var picker: HBoxContainer

var monster_chosen: int = -1

func _ready() -> void:
	for i in picker.get_child_count():
		var button = picker.get_child(i)
		button.pressed.connect(use_item.bind(i + 1))

func display_inventory():
	var inventory = InventoryManager.inventory
	for i in inventory.size():
		var item = inventory[i]["item"]
		var button = Button.new()
		button.text = "%s x%d" % [inventory[i]["item"].name, inventory[i]["quantity"]]
		button.pressed.connect(on_time_clicked.bind(item))
		container.add_child(button)

func on_time_clicked(item: Item):
	print("item:", item.name)
	picker_visibility(true)
	await monster_picked
	print("monster_chosen: ", monster_chosen)
	var action = ItemAction.new(BattleManager.player_actor, [monster_chosen], item)
	BattleManager.on_action_selected(action)
	monster_chosen = -1
	
func use_item(slot_index: int):
	monster_chosen = slot_index
	monster_picked.emit()
	
func picker_visibility(b: bool) -> void:
	picker.visible = b
	
func close():
	queue_free()
