extends Node2D

@export var text: String = ""

@export var monster_data: MonsterData
@export var move: Move

var npc

func _ready() -> void:
	npc = get_tree().get_first_node_in_group("TESTING_NPC")
	if npc:
		print("got NPC")
	
func _on_button_0_pressed() -> void:
	print("trying to turn NPC")
	EventBus.npc_command.emit("TURN_TO", npc, {"dir": Vector2.LEFT})
func _on_button_1_pressed() -> void:
	print("trying to turn NPC")
	EventBus.npc_command.emit("TURN_TO", npc, {"dir": Vector2.UP})
func _on_button_2_pressed() -> void:
	print("trying to turn NPC")
	EventBus.npc_command.emit("TURN_TO", npc, {"dir": Vector2.RIGHT})
func _on_button_3_pressed() -> void:
	print("trying to turn NPC")
	EventBus.npc_command.emit("TURN_TO", npc, {"dir": Vector2.DOWN})

func _on_walk_button_0_pressed() -> void:
	var array: Array[Vector2] = [Vector2.LEFT]
	EventBus.npc_command.emit("MOVE_TO", npc, {"path": array})
func _on_walk_button_1_pressed() -> void:
	var array: Array[Vector2] = [Vector2.UP]
	EventBus.npc_command.emit("MOVE_TO", npc, {"path": array})
func _on_walk_button_2_pressed() -> void:
	var array: Array[Vector2] = [Vector2.RIGHT]
	EventBus.npc_command.emit("MOVE_TO", npc, {"path": array})
func _on_walk_button_3_pressed() -> void:
	var array: Array[Vector2] = [Vector2.DOWN]
	EventBus.npc_command.emit("MOVE_TO", npc, {"path": array})
	
func _on_say_pressed() -> void:
	var lines: Array[String] = []
	print("sending \"\" , should print NPC lines")
	EventBus.npc_command.emit("SAY", npc, {"lines": lines})
	
func _on_say_npc_dial_pressed() -> void:
	var lines: Array[String] = [text]
	EventBus.npc_command.emit("SAY", npc, {"lines": lines})

func _on_hide_pressed() -> void:
	EventBus.npc_command.emit("HIDE", npc, {})

func _on_show_pressed() -> void:
	EventBus.npc_command.emit("SHOW", npc, {})
