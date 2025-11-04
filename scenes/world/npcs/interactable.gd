extends Interactable

@export var dialogues: Array[String]

@export_subgroup("Save Progress")
@export var dialogue_prog: int = 0

func on_save_game(_saved_data: Array[SavedData]):
	pass
	
func on_before_load_game():
	pass
	
func on_load_game(_saved_data_array: Array[SavedData]):
	pass
	
func setup():
	pass
	
func interact(_interactor = null):
	dialogue()

func dialogue():
	var dialogue_to_show: String = dialogues[dialogue_prog]
	DialogueManager.show_dialogue(dialogue_to_show)
	dialogue_prog = (dialogue_prog + 1) % dialogues.size()
