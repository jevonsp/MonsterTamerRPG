class_name Recoil extends BattleEffect

func apply(actor_ref: Monster, target_ref: Monster, move_ref) -> void:
	super(actor_ref, target_ref, move_ref)
	
	var damage = calculate_damage()
	
	await actor.take_damage(damage)
	DialogueManager.show_dialogue("%s took recoil damage", false)
	await DialogueManager.dialogue_closed
	
func calculate_damage():
	var monster = actor as Monster
	var hp = monster.max_hitpoints
	var damage = int(hp / 10.0)
	return max(damage, 1)
