extends Node

var battle_invent_preload = preload("res://scenes/battle/battle_inventory/battle_inventory.tscn")

var inventory: Array[Dictionary] = []

func add_items(item: Item, quantity: int = 1) -> void:
	for i in inventory.size():
		if inventory[i]["item"] == item:
			inventory[i]["quantity"] += quantity
			print("Added %d x %s (now have %d total)" % [quantity, item.name, inventory[i]["quantity"]])
			return
	inventory.append({"item": item, "quantity": quantity})
	print("Added %d x %s (new item)" % [quantity, item.name])

func show_inventory():
	var battle_inventory_scene = battle_invent_preload.instantiate()
	add_child(battle_inventory_scene)
	battle_inventory_scene.display_inventory()
