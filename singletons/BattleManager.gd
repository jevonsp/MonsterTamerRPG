extends Node

var battle = preload("res://scenes/battle/battle.tscn")

var enemy_party: Array[Monster] = []
var player_actor: Monster
var enemy_actor: Monster
var enemy_actor2: Monster

var single_battle: bool = true

var turn_actions: Array = []
	
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
	player_actor = PartyManager.party[0]
	var battle_scene = battle.instantiate()
	add_child(battle_scene)
	battle_scene.setup_battle()
	
func on_action_selected(action: BattleAction):
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
	var enemy_action = MoveAction.new(monster, [player_actor], enemy_move)
	turn_actions.append(enemy_action)
	
func execute_turn():
	for action in turn_actions:
		if action.actor.is_fainted:
			print("skip action here, is_fainted: ", action.actor.is_fainted)
			continue
		print("executing action: ", action.type)
		await action.execute()
		await get_tree().create_timer(0.5).timeout
	turn_actions.clear()
