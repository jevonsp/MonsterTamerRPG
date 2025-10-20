extends CanvasLayer

func _ready():
	pass

func _input(event: InputEvent) -> void:
	if self != UiManager.ui_stack.back():
		return
	
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
	UiManager.pop_ui(self)
