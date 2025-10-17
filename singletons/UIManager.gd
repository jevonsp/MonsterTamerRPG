extends Node

var processing: bool = true

var menu_scene = preload("res://scenes/menu/menu.tscn")

func _ready() -> void:
	GameManager.input_state_changed.connect(_on_input_state_changed)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if get_tree().get_first_node_in_group("player").is_moving:
			return
		GameManager.input_state = GameManager.InputState.MENU
		show_menu()
	
func _on_input_state_changed(new_state) -> void:
	match new_state:
		GameManager.InputState.OVERWORLD:
			processing = true
		GameManager.InputState.BATTLE:
			processing = false
		GameManager.InputState.DIALOGUE:
			processing = false
		GameManager.InputState.MENU:
			processing = true
		GameManager.InputState.INACTIVE:
			pass

func show_menu():
	var menu = menu_scene.instantiate()
	add_child(menu)
