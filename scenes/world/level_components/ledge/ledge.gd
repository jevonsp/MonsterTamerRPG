extends Area2D

enum Direction {ABOVE, BELOW, LEFT, RIGHT}
@export var allowed_direction: Direction

func _ready() -> void:
	add_to_group("ledge")
	
