extends Node

var player: CharacterBody2D
var overworld: TileMapLayer

func enter_map(packed_scene: PackedScene, entrance: String, exit_point: Vector2):
	
	var interior = packed_scene.instantiate()
	get_tree().root.add_child(interior)
	interior.global_position = Vector2(5000, 0)
	var entrance_point
	if entrance == null:
		entrance_point = interior.find_child("Entrance")
	else:
		entrance_point = interior.find_child(entrance)
	player.global_position = entrance_point.global_position
	player.set_meta("exit_point", exit_point)
	
func exit_map():
	
	var exit_point = player.get_meta("exit_point", Vector2.ZERO)
	player.global_position = exit_point
