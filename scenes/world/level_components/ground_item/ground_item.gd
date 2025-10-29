extends Interactable

@export var item: Item

func interact(_interactor = null):
	InventoryManager.add_items(item, 1)
	dialogue()
	obtain()
	
func dialogue():
	DialogueManager.show_dialogue("You got a %s!" % item.name)
	await DialogueManager.dialogue_closed
	
func on_save_game(saved_data: Array[SavedData]):
	var my_data = SavedData.new()
	my_data.scene_path = scene_file_path
	my_data.node_path = get_path()
	my_data.obtained = obtained
	saved_data.append(my_data)
	
func on_load_game(saved_data_array: Array[SavedData]):
	for data in saved_data_array:
		if data.node_path == get_path():
			print("matching node path")
			obtained = data.obtained
	print("obtained: ", obtained)
	if obtained:
		obtain()
