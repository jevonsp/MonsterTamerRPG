extends Node2D

@export var move: Move

func _on_button_pressed() -> void:
	print("moves before: ", PartyManager.party[0].moves)
	PartyManager.party[0].add_move(move)
	print("moves after: ", PartyManager.party[0].moves)
	
