extends Interactable

@export var respawn_point: bool = true

func interact():
	dialogue()
	
func dialogue():
	var confirm = await DialogueManager.show_choice("Do you want to heal?")
	if confirm:
		for monster in PartyManager.party:
			if monster:
				monster.heal(0, true)
				monster.status = null
				monster.revive()
		if respawn_point:
			var player = get_tree().get_first_node_in_group("player")
			player.save_position()
	else:
		print("cancel")
