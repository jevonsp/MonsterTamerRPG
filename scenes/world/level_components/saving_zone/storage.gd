extends Interactable

func _ready() -> void:
	add_to_group("interactable")

func interact(_interactor = null):
	print("interacted with storage")
	dialogue()
	
func dialogue():
	DialogueManager.show_dialogue("Welcome to the Storage System!", true)
	UiManager.push_ui(UiManager.storage_scene)
