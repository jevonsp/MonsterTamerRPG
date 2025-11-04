extends Area2D

@export var active: bool = true

func _ready() -> void:
	add_to_group("can_save")
	
	
func on_save_game(saved_data: Array[SavedData]):
	var my_data = SavedData.new()
	my_data.node_path = get_path()
	my_data.active = active
	saved_data.append(my_data)
	
func on_load_game(saved_data_array: Array[SavedData]):
	for data in saved_data_array:
		if data.node_path == get_path():
			active = data.active
	monitoring = active
		 
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("player entered")
