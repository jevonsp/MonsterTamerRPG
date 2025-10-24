extends Node2D

@export var monster_data: MonsterData
@export var move: Move

func make_test_monster():
	PartyManager.make_monster(monster_data, 5)

func _on_button_2_pressed() -> void:
	var monster = PartyManager.party[0]
	monster.add_move(move)
