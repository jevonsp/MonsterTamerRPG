class_name EventComponent extends Node

@export var event: String = ""
@export var is_active: bool = true

func _ready() -> void:
	if event == "":
		print("no event on %s" % [get_parent().name])
		
func trigger() -> void:
	if event == "":
		print("no event")
		return
	print("event component triggered")
	EventBus.event_triggered.emit(event)
