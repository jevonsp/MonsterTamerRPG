extends Node

@export var story_flags: Dictionary = {
	
}
@export var tutorial_progress: Dictionary = {
	
}
var event_handlers: Dictionary = {
	"MONSTER_COLLECTED": collected_first_monster
}

func _ready() -> void:
	EventBus.event_triggered.connect(_on_event_triggered)
	
func _on_event_triggered(event: String) -> void:
	print("story manager got event")
	if event_handlers.has(event):
		event_handlers[event].call()
	else:
		push_warning("no handler for event")
		
func collected_first_monster():
	print("collected first monster")
	var npc := get_tree().get_first_node_in_group("")
	if npc:
		EventBus.npc_command.emit()
