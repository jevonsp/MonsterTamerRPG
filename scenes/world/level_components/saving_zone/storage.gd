extends Interactable

func _ready() -> void:
	add_to_group("interactable")

func interact():
	print("interacted with storage")
	dialogue()
	
func dialogue():
	DialogueManager.show_dialogue("Not yet implemented!", true)
