class_name SwitchComponent extends EffectComponent

@export_enum("RANDOM_ALIVE", "FORCE_CHOICE", "FIRST_ALIVE") var switch_mode: String = "RANDOM_ALIVE"
@export var switch_message: String = "{monster} is switching out!"
@export var can_be_prevented: bool = true
@export var is_free: bool = true

func apply(actor: Monster, _target: Monster, _context: Dictionary) -> bool:
	if can_be_prevented:
		for stacking_status in actor.stacking_statuses:
			if stacking_status and not await stacking_status.can_switch(actor):
				return true
				
	if switch_message != "":
		var message = switch_message.format({"monster": actor.name})
		DialogueManager.show_dialogue(message, true)
		await DialogueManager.dialogue_closed
		
	match switch_mode:
		"RANDOM_ALIVE": await switch_random_alive(actor)
		"FORCE_CHOICE": await switch_force_choice(actor)
		"FIRST_ALIVE": await switch_first_alive(actor)
		
	return true
		
func switch_random_alive(monster: Monster):
	var party = get_party(monster)
	var valid_targets: Array = []
	
	for i in range(1, party.size()):
		if not party[i].is_fainted:
			valid_targets.append(i)
	if valid_targets.is_empty():
		print("Switch Component failed: No targets.")
		return
		
	var random_index = valid_targets[randi() % valid_targets.size()]
	await execute_switch(monster, random_index)
	
func switch_force_choice(monster: Monster):
	if monster == BattleManager.player_actor:
		await BattleManager.force_switch()
	else:
		await switch_random_alive(monster)
	
func switch_first_alive(monster: Monster):
	var party = get_party(monster)
	for i in range(1, party.size()):
		if not party[i].is_fainted:
			await execute_switch(monster, i)
			return
	
func get_party(monster: Monster) -> Array[Monster]:
	if monster == BattleManager.player_actor:
		return PartyManager.party
	else:
		return BattleManager.enemy_party
	
func execute_switch(monster: Monster, switch_index: int) -> void:
	var switch_action = SwitchAction.new(monster, [], switch_index)
	await switch_action.exeucte()
