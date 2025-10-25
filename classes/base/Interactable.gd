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
	
func on_save_game(saved_data: Array[SavedData]):
	var my_data = SavedData.new()
	my_data.scene_path = scene_file_path
	my_data.node_path = get_path()
	my_data.obtained = obtained
	saved_data.append(my_data)
	
func on_before_load_game():
	pass
	
func on_load_game(saved_data_array: Array[SavedData]):
	for data in saved_data_array:
		if data.node_path == get_path():
			print("matching scene path")
			obtained = data.obtained
	print("obtained: ", obtained)
	if obtained:
		obtain()
	
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
