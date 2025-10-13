extends Node

var battle = preload("res://scenes/battle/battle.tscn")
var battle_party_scene = preload("res://scenes/battle/battle_party/battle_party.tscn")

var enemy_party: Array[Monster] = []

var player_actor: Monster # 0
var enemy_actor: Monster # 1

var player_actor2: Monster # 2
var enemy_actor2: Monster # 3

var single_battle: bool = true

var turn_actions: Array = []
var processing_turn: bool = false
var in_battle: bool = false
	
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
		
	enemy_actor = enemy_party[0]
	
func start_battle():
	in_battle = true
	print(PartyManager.party)
	player_actor = PartyManager.get_first_alive()
	var battle_scene = battle.instantiate()
	add_child(battle_scene)
	battle_scene.setup_battle()
	print("enemy party size: ", range(enemy_party.size()))
	
func on_action_selected(action: BattleAction):
	if processing_turn:
		return
	match action.type:
		"MOVE": print("action selected: MOVE. Move name: ", action.move.name)
		"SWITCH": print("action selected: SWITCH. Switch target: ")
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
	processing_turn = true
	for action in turn_actions:
		if action.actor.is_fainted:
			force_switch()
			turn_actions.clear()
			return
		if not in_battle:
			return
		print("executing action: ", action.type)
		await action.execute()
		await get_tree().create_timer(Settings.game_speed).timeout
		if await check_victory(): 
			continue
		if await check_loss(): 
			continue
	turn_actions.clear()
	processing_turn = false
	
func check_victory():
	var alive: int = 0
	for monster in enemy_party:
		if not monster.is_fainted:
			alive += 1
	if alive == 0:
		win()
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
	in_battle = false
	print("win here")
	end_battle()
	
func lose():
	in_battle = false
	print("lose here")
	end_battle()
	
func force_switch():
	if not in_battle:
		return
	print("force_switch here")
	var battle_party = battle_party_scene.instantiate()
	add_child(battle_party)
	EventBus.free_switch.emit()
	await EventBus.battle_switch
	await get_tree().create_timer(Settings.game_speed).timeout
	print("free switch complete")
	
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
	
func get_next_enemy_monster() -> int:
	for i in range(enemy_party.size()):
		if not enemy_party[i].is_fainted:
			return i
	return -1
	
func end_battle():
	enemy_party.clear()
	print("enemy_party: ", enemy_party)
	player_actor = null
	print("player_actor: ", player_actor)
	enemy_actor = null
	print("enemy_actor: ", enemy_actor)
	print("actors/party cleared")
