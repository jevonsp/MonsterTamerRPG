extends Node

var enemy_party: Array[Monster] = []

var player_actor: Monster # 0
var enemy_actor: Monster # 1

var player_actor2: Monster # 2
var enemy_actor2: Monster # 3

var single_battle: bool = true

var turn_actions: Array = []
var processing_turn: bool = false
var in_battle: bool = false
var battle_reference: Node = null

var escape_attempts: int = 0
var escaped: bool = false

func _ready() -> void:
	EventBus.battle_reference.connect(_on_battle_reference)
	EventBus.request_battle_actors.connect(_on_battle_actors_requested)
	
func add_enemies(monster_datas: Array[MonsterData], lvls: Array[int]) -> void:
	if monster_datas.size() != lvls.size():
		print("add_enemies: arrays must be the same size")
		return
	
	for i in range(monster_datas.size()):
		var monster_data = monster_datas[i]
		var lvl = lvls[i]
		var monster = Monster.new()
		monster.setup_monster(monster_data, lvl)
		enemy_party.append(monster)
		print("enemy party added: ", monster.name)
		print("enemy_party: ", enemy_party)
		
	enemy_actor = enemy_party[0]
	print("enemy_actor: ", enemy_actor)
	
func start_battle():
	in_battle = true
	processing_turn = false
	print(PartyManager.party)
	player_actor = PartyManager.get_first_alive()
	print("player_actor: ", player_actor)
	player_actor.getting_exp = true
	await get_tree().process_frame
	print("enemy party size: ", enemy_party.size())
	EventBus.battle_manager_ready.emit()
	
func _on_battle_reference(node: Node):
	battle_reference = node
	
func _on_battle_actors_requested():
	print("_on_battle_actors_requested recieved, battle actors sent")
	EventBus.player_battle_actor_sent.emit(player_actor)
	EventBus.enemy_battle_actor_sent.emit(enemy_actor)
	
func on_action_selected(action: BattleAction):
	if processing_turn:
		return
	match action.type:
		"MOVE": print("action selected: MOVE. Move name: ", action.move.name)
		"SWITCH": print("action selected: SWITCH.")
		"ITEM": print("action selected: ITEM. Item name: ")
		"RUN": print("action selected: RUN")
	turn_actions.append(action)
	get_enemy_action(enemy_actor)
	execute_turn()
	
func get_enemy_action(monster: Monster):
	var index = randi_range(0, monster.moves.size() - 1)
	var enemy_move = monster.moves[index]
	var enemy_target_index: int = -1
	if single_battle:
		enemy_target_index = 0
	elif not single_battle:
		enemy_target_index = [0, 2].pick_random()
	var enemy_action = MoveAction.new(monster, [enemy_target_index], enemy_move)
	turn_actions.append(enemy_action)
	print("got enemy action")
	
func resolve_targets(target_type: String, actor: Monster) -> Array[Monster]:
	var result: Array[Monster] = []
	match target_type:
		"ENEMY": result.append(get_opposing_actor(actor))
		"ALLY": result.append(get_ally_actor(actor))
		"SELF": result.append(actor)
		"ENEMIES": result.append(get_opposing_party(actor))
		"ALLIES": result.append(get_ally_party(actor))
		"ALL": result += get_ally_party(actor) + get_opposing_party(actor)
	return result
	
func get_opposing_actor(actor: Monster) -> Monster:
	var opponents = []
	if actor in [player_actor, player_actor2]:
		opponents = [enemy_actor, enemy_actor2]
	elif actor in [enemy_actor, enemy_actor2]:
		opponents = [player_actor, player_actor2]
	return opponents[0] if single_battle else opponents.pick_random()
	
func get_ally_actor(actor: Monster) -> Monster:
	var allies = []
	if actor in [player_actor, player_actor2]:
		allies = [player_actor, player_actor2]
	elif actor in [enemy_actor, enemy_actor2]:
		allies = [enemy_actor, enemy_actor2]
	return allies[0] if single_battle else allies.pick_random()
	
func get_opposing_party(actor: Monster) -> Array[Monster]:
	var opponents = []
	if actor in [player_actor, player_actor2]:
		opponents = [enemy_actor, enemy_actor2]
	elif actor in [enemy_actor, enemy_actor2]:
		opponents = [player_actor, player_actor2]
	return opponents
	
func get_ally_party(actor: Monster) -> Array[Monster]:
	var allies = []
	if actor in [player_actor, player_actor2]:
		allies = [player_actor, player_actor2]
	elif actor in [enemy_actor, enemy_actor2]:
		allies = [enemy_actor, enemy_actor2]
	return allies
	
func execute_turn():
	print("turn_actions: ", turn_actions)
	processing_turn = true
	
	turn_actions.sort_custom(func(a, b):
		if a.priority != b.priority:
			return a.priority > b.priority
		return a.actor.get_stat("speed") > b.actor.get_stat("speed")
		)
	
	for action in turn_actions:
		if not in_battle:
			return
		if player_actor.is_fainted:
			force_switch()
			turn_actions.clear()
			return
		print("executing action: ", action.type)
		await action.execute()
		if not in_battle:
			return
		await get_tree().create_timer(Settings.game_speed).timeout
		if enemy_actor and enemy_actor.is_fainted:
			await give_exp()
		if enemy_actor2 and enemy_actor2.is_fainted:
			await give_exp()
		if await check_victory(): 
			return
		if await check_loss(): 
			return
	turn_actions.clear()
	processing_turn = false
	
func give_exp():
	var exp_to_give = enemy_actor.grant_exp()
	print("exp_to_give: ", exp_to_give)
	for monster in PartyManager.party:
		if monster.getting_exp:
			monster.gain_exp(exp_to_give)
			await EventBus.exp_done_animating
	
func check_victory():
	var alive: int = 0
	for monster in enemy_party:
		if not monster.is_fainted:
			alive += 1
	if alive == 0:
		win()
		return true
	if escaped == true:
		escape()
		return true
	if enemy_actor.is_fainted:
		await force_enemy_switch()
	return false
	
func check_loss():
	var alive: int = 0
	for monster in PartyManager.party:
		if not monster.is_fainted:
			alive += 1
	if alive == 0:
		lose()
		return true
	if player_actor.is_fainted:
		await force_switch()
	return false
	
func win():
	if not in_battle:
		return
	DialogueManager.show_dialogue("You win!")
	await DialogueManager.dialogue_closed
	end_battle()
	
func lose():
	if not in_battle:
		return
	DialogueManager.show_dialogue("You lose!")
	await DialogueManager.dialogue_closed
	end_battle()
	
func escape():
	if not in_battle:
		return
	DialogueManager.show_dialogue("Escaped safely")
	await DialogueManager.dialogue_closed
	end_battle()
	
func captured(target: Monster) -> void:
	if not in_battle:
		return
	if single_battle:
		print("capture success win here")
		end_battle()
	else:
		print("no targeting implemented, target captured:", target)
		print("capture success win here")
		end_battle()
			
func force_switch():
	if not in_battle:
		return
	print("force_switch here")
	var battle_party = UiManager.show_party()
	add_child(battle_party)
	EventBus.free_switch.emit()
	await EventBus.free_switch_chosen
	await get_tree().create_timer(Settings.game_speed).timeout
	print("free switch complete")
	update_battle_actors()
	
func force_enemy_switch():
	var next = get_next_enemy_monster()
	if next == -1:
		win()
		return
	var switch = SwitchAction.new(enemy_actor, [player_actor], next)
	switch.execute()
	await EventBus.battle_switch
	await get_tree().create_timer(Settings.game_speed).timeout
	print("free enemy switch complete")
	update_battle_actors()
	
func get_next_enemy_monster() -> int:
	for i in range(enemy_party.size()):
		if not enemy_party[i].is_fainted:
			return i
	return -1
	
func update_battle_actors() -> void:
	var p1_temp = player_actor
	var p2_temp = player_actor2
	var e1_temp = enemy_actor
	var e2_temp = enemy_actor2
	
	if player_actor: player_actor = PartyManager.party[0]
	if player_actor2: player_actor2 = PartyManager.party[1]
	if enemy_actor: enemy_actor = enemy_party[0]
	if enemy_actor2: enemy_actor2 = enemy_party[1]
	
	var old: Monster
	var new: Monster
	
	for monster in [p1_temp, p2_temp, e1_temp, e2_temp]:
		if monster not in [player_actor, player_actor2, enemy_actor, enemy_actor2]:
			old = monster
	for monster in [player_actor, player_actor2, enemy_actor, enemy_actor2]:
		if monster not in [p1_temp, p2_temp, e1_temp, e2_temp]:
			new = monster
	
	EventBus.switch_animation.emit(old, new)
	
func end_battle():
	await get_tree().create_timer(Settings.game_speed).timeout
	in_battle = false
	escaped = false
	battle_reference.clear_maps()
	UiManager.clear_ui()
	battle_reference = null
	for monster in PartyManager.party:
		monster.getting_exp = false
	enemy_party.clear()
	print("enemy_party: ", enemy_party)
	player_actor = null
	print("player_actor: ", player_actor)
	enemy_actor = null
	print("enemy_actor: ", enemy_actor)
	print("actors/party cleared")
	escape_attempts = 0
	turn_actions.clear()
	
