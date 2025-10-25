extends Interactable

@export var item: Item

func interact():
	InventoryManager.add_items(item, 1)
	dialogue()
	obtain()
	
func dialogue():
	DialogueManager.show_dialogue("You got a %s!" % item.name)
	await DialogueManager.dialogue_closed
	
