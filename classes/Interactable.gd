class_name Interactable extends Area2D

var can_interact: bool = false

func _ready() -> void:
	add_to_group("interactable")
	setup()
	
func setup():
	pass
	
func interact():
	pass
