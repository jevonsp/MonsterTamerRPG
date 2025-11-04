class_name DialogueBehavior extends NPCBehavior

@export var dialogues: Array[String] = []
@export var current_index: int = 0

func execute(_interactor, _npc: NPC) -> void:
	if dialogues.size() == 0:
		return
		
	DialogueManager.show_dialogue(dialogues[current_index])
	await DialogueManager.dialogue_closed
	current_index = (current_index + 1) % dialogues.size()
