class_name Shop extends NPC

@export var inventory: Array[ItemSlot] = []

func interact(interactor = null) -> void:
	turn_towards(interactor)
	await get_tree().create_timer(0.1).timeout
	say_dialogue()
	await DialogueManager.dialogue_closed
	open_store()
	
func open_store():
	var shop = UiManager.push_ui(UiManager.shop_scene)
	shop.set_inventory(inventory, self)
	
func on_save_game(saved_data: Array[SavedData]):
	var my_data = SavedData.new()
	my_data.node_path = get_path()
	my_data.inventory = inventory
	saved_data.append(my_data)
	
func on_load_game(saved_data_array: Array[SavedData]):
	for data in saved_data_array:
		if data.node_path == get_path():
			print("got node path")
			inventory = data.inventory
