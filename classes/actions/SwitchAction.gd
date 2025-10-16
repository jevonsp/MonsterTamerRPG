class_name SwitchAction extends BattleAction

var switch_index: int

func _init(actor_ref: Monster, target_refs: Array, index: int) -> void:
	priority = 6
	switch_index = index
	super("SWITCH", switch_index, actor_ref, target_refs)
	
func execute() -> void:
	# Determine which party we're switching from
	var party: Array[Monster]
	var is_player_switch = false
	
	# Check if this is a player switch or enemy switch
	if actor == BattleManager.player_actor or (BattleManager.player_actor and PartyManager.party.has(actor)):
		party = PartyManager.party
		is_player_switch = true
	else:
		party = BattleManager.enemy_party
		is_player_switch = false
	
	# Validation
	if party.size() == 0:
		push_error("Cannot switch: party is empty")
		return
	
	if switch_index < 0 or switch_index >= party.size():
		push_error("Invalid switch index: " + str(switch_index))
		return
	
	if party[switch_index].is_fainted:
		push_error("Cannot switch to fainted monster")
		return
	
	# Store names before the swap
	var old_monster_name = party[0].name
	var new_monster_name = party[switch_index].name
	
	# Perform the switch
	var _out = 0
	var _in = switch_index
	
	var temp = party[_out]
	party[_out] = party[_in]
	party[_in] = temp
	
	print(old_monster_name, " switched out for ", new_monster_name)
	
	# Update the active actor reference
	if is_player_switch:
		BattleManager.player_actor = party[0]
		party[0].getting_exp = true
	else:
		BattleManager.enemy_actor = party[0]
	
	EventBus.switch_animation.emit(temp, party[_in])
	await EventBus.switch_done_animating
