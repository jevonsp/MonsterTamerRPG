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
	if event_handlers.has(event):
		event_handlers[event].call()
	else:
		push_warning("no handler for event")
		
func collected_first_monster():
	var npcs := get_tree().get_nodes_in_group("MONSTER_COLLECTED")
	if npcs:
		for npc in npcs:
			var path: Array[Vector2] = [Vector2(0,1)]
			EventBus.npc_command.emit("TURN_TO", npc, {"dir": Vector2.DOWN})
			await EventBus.npc_command_completed
			EventBus.npc_command.emit("MOVE_TO", npc, {"path": path})
			await EventBus.npc_command_completed
			EventBus.npc_command.emit("TURN_TO", npc, {"dir": Vector2.LEFT})
			await EventBus.npc_command_completed
			var lines: Array[String] = ["Nice! You can move on now"]
			EventBus.npc_command.emit("SAY", npc, {"lines": lines})
			await EventBus.npc_command_completed
			var dialogues : Array[String] = ["Bye Felicia!"]
			npc.dialogues = dialogues
