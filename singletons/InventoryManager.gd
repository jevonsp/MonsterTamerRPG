extends Node

var battle_invent_preload = preload("res://scenes/battle/battle_inventory/battle_inventory.tscn")

var inventory: Dictionary[Item, int] = {}

func add_items(item: Item, quantity: int = 1) -> void:
	inventory[item] = inventory.get(item, 0) + quantity
	print("Added %d x %s (now have %d total)" % [quantity, item.name, inventory[item]])

func show_inventory():
	var battle_inventory_scene = battle_invent_preload.instantiate()
	add_child(battle_inventory_scene)
