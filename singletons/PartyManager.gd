extends Node

var party: Array[Monster] = []

func add_monster(monster_data: MonsterData, lvl: int) -> void:
	if not party.size() < 6:
		print("no more room in party!")
		return
	var monster = Monster.new()
	monster.setup_monster(monster_data, lvl)
	party.append(monster)
