extends Interactable

@export var inventory: Array[ItemSlot] = []
@export var welcome_text: String

func interact():
	print("interacted")
	dialogue()
	
func dialogue():
	var string = "Welcome to my shop!"
	if welcome_text:
		string = welcome_text
	DialogueManager.show_dialogue(string, true)
	await DialogueManager.dialogue_closed
	open_store()
	
func open_store():
	var shop = UiManager.push_ui(UiManager.shop_scene)
	shop.set_inventory(inventory)
