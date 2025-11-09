extends Interactable

@export var string_array: Array[String] = []
@export var string_index: int = 0

func interact(_interactor = null):
	for i in string_array.size():
		DialogueManager.show_dialogue(string_array[i])
		string_index = (string_index + 1) % string_array.size()
		await DialogueManager.dialogue_closed
	string_index = 0
