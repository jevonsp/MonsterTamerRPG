extends Interactable

@export var trainer: Trainer

func interact():
	print("trainer interacted")
	dialogue()
	
func dialogue():
	if not trainer.defeated:
		DialogueManager.show_dialogue(trainer.fight_text)
		await DialogueManager.dialogue_closed
		trainer.build_encounter()
	elif trainer.defeated:
		DialogueManager.show_dialogue(trainer.post_fight_text)
		await DialogueManager.dialogue_closed
