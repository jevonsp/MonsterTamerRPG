extends CanvasLayer

@export var label: Label
@export var arrow: Sprite2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("yes") or event.is_action_pressed("no"):
		EventBus.advance_dialogue.emit()
		get_viewport().set_input_as_handled()
	
func display_text(text: String) -> void:
	label.text = text
	print(text)
	
func blink_arrow():
	arrow.visible = !arrow.visible
