extends CanvasLayer

signal inventory_options_closed

func _ready():
	pass

func _input(event: InputEvent) -> void:
	print("Options _input received: ", event)
	if event.is_action_pressed("yes") \
	or event.is_action_pressed("no") or \
	event.is_action_pressed("up") or \
	event.is_action_pressed("down"):
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("no"):
		print("no pressed")
		close()
		
func close():
	inventory_options_closed.emit()
	get_parent().remove_child(self)
	queue_free()
