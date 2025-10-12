extends Node

var party: Array[Monster] = []

var party_preload = preload("res://scenes/battle/battle_party/battle_party.tscn")

func add_monster(monster_data: MonsterData, lvl: int) -> void:
	if not party.size() < 6:
		print("no more room in party!")
		return
	var monster = Monster.new()
	monster.setup_monster(monster_data, lvl)
	party.append(monster)
	
func get_first_alive() -> Monster:
	for monster in party:
		if not monster.is_fainted:
			return monster
	return null
	
func show_party():
	var party_scene = party_preload.instantiate()
	add_child(party_scene)
