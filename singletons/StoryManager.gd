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
	var npcs := get_tree().get_nodes_in_group("TUTORIAL_BLOCKER")
	if npcs:
		for npc in npcs:
			EventBus.npc_command.emit("HIDE", npc, {})
