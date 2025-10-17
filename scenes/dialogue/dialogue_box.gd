extends CanvasLayer

@export var label: Label

func _ready() -> void:
	print("Dialogue Manager waiting for continue")
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("yes") or event.is_action_pressed("no"):
		EventBus.advance_dialogue.emit()
	
func display_text(text: String) -> void:
	label.text = text
	print(text)
