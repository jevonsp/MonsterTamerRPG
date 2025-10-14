class_name SwitchAction extends BattleAction

var switch_index: int

func _init(actor_ref: Monster, target_refs: Array, index: int) -> void:
	priority = 6
	switch_index = index
	super("SWITCH", switch_index, actor_ref, target_refs)
	
func execute() -> void:
	print("executing switch")
	
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
	
	print("party before:")
	for monster in party:
		print(" - ", monster)
	
	if is_player_switch:
		print("player_actor: ", BattleManager.player_actor)
	else:
		print("enemy_actor: ", BattleManager.enemy_actor)
	
	# Perform the switch
	var _out = 0
	var _in = switch_index
	
	var temp = party[_out]
	party[_out] = party[_in]
	party[_in] = temp
	
	# Update the active actor reference
	if is_player_switch:
		BattleManager.player_actor = party[0]
		party[0].getting_exp = true
	else:
		BattleManager.enemy_actor = party[0]
	
	print("party after:")
	for monster in party:
		print(" - ", monster)
	
	if is_player_switch:
		print("player_actor: ", BattleManager.player_actor)
	else:
		print("enemy_actor: ", BattleManager.enemy_actor)
	
	EventBus.battle_switch.emit()
