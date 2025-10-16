extends CanvasLayer

func display_text(text: String) -> void:
	print(text)

func _on_temp_button_pressed() -> void:
	EventBus.advance_dialogue.emit()
