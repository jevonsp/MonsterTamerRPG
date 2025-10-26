class_name Interactable extends Area2D

@export var obtained: bool = false

var shape: Node2D

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("can_save")
	for child in get_children():
		if child is CollisionShape2D:
			shape = child
			break
		if child is CollisionPolygon2D:
			shape = child
			break
	print("shape: ", shape)
	setup()
	
func on_save_game(_saved_data: Array[SavedData]):
	pass
	
func on_before_load_game():
	pass
	
func on_load_game(_saved_data_array: Array[SavedData]):
	pass
	
func setup():
	pass
	
func interact():
	pass

func dialogue():
	pass
	
func obtain():
	print("obtain called")
	obtained = true
	visible = false
	shape.disabled = true
	monitoring = false
