class_name Healer extends NPC

@export var respawn_point: bool = true
@export var post_dialogue: String = ""

func interact(interactor = null) -> void:
	turn_towards(interactor)
	var confirm = await DialogueManager.show_choice(dialogues[0])
	if confirm:
		heal()
	await get_tree().create_timer(Settings.game_speed).timeout
	say_dialogue(post_dialogue)
	
func heal():
	for monster in PartyManager.party:
			if monster:
				monster.heal(0, true)
				monster.status = null
				monster.revive()
	if respawn_point:
			var player = get_tree().get_first_node_in_group("player")
			player.save_position()
