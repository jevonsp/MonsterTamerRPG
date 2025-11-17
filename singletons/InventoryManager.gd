extends Node

var inventory: Array[Dictionary] = []
var money: int = 0

func _ready() -> void:
	pass
	
func add_items(item: Item2, quantity: int = 1) -> void:
	for i in inventory.size():
		if inventory[i]["item"] == item:
			inventory[i]["quantity"] += quantity
			print("Added %d x %s (now have %d total)" % [quantity, item.name, inventory[i]["quantity"]])
			return
	inventory.append({"item": item, "quantity": quantity})
	print("Added %d x %s (new item)" % [quantity, item.name])
	
func remove_items(item: Item2, quantity: int = 1) -> void:
	for i in inventory.size():
		if inventory[i]["item"] == item:
			inventory[i]["quantity"] -= quantity
			print("Removed %d x %s (now have %d total)" % [quantity, item.name, inventory[i]["quantity"]])
			if inventory[i]["quantity"] <= 0:
				print("%s removed completely" % item.name)
				inventory.remove_at(i)
				var inventory_node = get_tree().get_first_node_in_group("inventory")
				if inventory_node == null:
					return
				print("inventory_node: ", inventory_node)
				inventory_node.update_display()
			return
	print("Tried to remove %s, but it wasn't found in inventory" % item.name)
	
func swap_items(from_index: int, to_index: int) -> void:
	var temp = inventory[from_index]
	inventory[from_index] = inventory[to_index]
	inventory[to_index] = temp
	
