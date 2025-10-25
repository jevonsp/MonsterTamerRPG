extends Interactable

func _ready() -> void:
	add_to_group("interactable")

func interact():
	print("interacted with saving zone")
	dialogue()
	
func dialogue():
	var confirm = await DialogueManager.show_choice("Do you want to save?")
	if confirm:
		SaverLoader.save_game()
	else:
		print("no")
