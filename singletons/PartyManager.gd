extends Node

var party: Array[Monster] = []

var party_preload = preload("res://scenes/party/single_party.tscn")

func make_monster(monster_data: MonsterData, lvl: int) -> void:
	if not party.size() < 6:
		print("no more room in party!")
		return
	
	var monster = Monster.new()
	monster.setup_monster(monster_data, lvl)
	party.append(monster)
	print("party: ", party)
	
func add_monster(monster: Monster) -> void:
	if not party.size() < 6:
		print("no more room in party!")
		return
	party.append(monster)
	print("party: ", party)
	
func get_first_alive() -> Monster:
	for monster in party:
		if not monster.is_fainted:
			return monster
	return null
	
func show_party():
	var party_scene = party_preload.instantiate()
	add_child(party_scene)
	
func swap_party(from_index: int, to_index: int, free_switch: bool = true) -> void:
	if free_switch:
		var temp = party[from_index]
		party[from_index] = party[to_index]
		party[to_index] = temp
	else :
		var switch = SwitchAction.new(BattleManager.player_actor, [BattleManager.enemy_actor], from_index)
		EventBus.free_switch_chosen.emit()
		BattleManager.on_action_selected(switch)
