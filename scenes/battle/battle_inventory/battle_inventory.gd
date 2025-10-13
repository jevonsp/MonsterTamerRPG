extends CanvasLayer

func _on_button_1_pressed() -> void:
	use_item(0)
	
func use_item(slot_index: int):
	close()
	
func close():
	queue_free()
