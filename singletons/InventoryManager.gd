extends Node

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
	var inventory_scene = UiManager.show_inventory()
	add_child(inventory_scene)
	inventory_scene.display_inventory()
