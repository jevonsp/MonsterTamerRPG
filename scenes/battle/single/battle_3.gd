extends CanvasLayer

@export var visuals: CanvasLayer

func _ready() -> void:
	print("battle3 _ready called")
	UiManager.push_ui(UiManager.battle_options_scene)
