extends Interactable

func interact():
	dialogue()
	
func dialogue():
	var confirm = await DialogueManager.show_choice("Do you want to heal?")
	if confirm:
		for monster in PartyManager.party:
			monster.heal(0, true)
	else:
		print("cancel")
