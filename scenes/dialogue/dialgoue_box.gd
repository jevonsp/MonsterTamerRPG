extends CanvasLayer

func _ready() -> void:
	print("Dialogue Manager waiting for continue")

func display_text(text: String) -> void:
	print(text)

func _on_temp_button_pressed() -> void:
	EventBus.advance_dialogue.emit()
