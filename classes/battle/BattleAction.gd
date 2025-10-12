class_name BattleAction extends RefCounted

var actor: Monster
var targets: Array
var type: String # "MOVE", "ITEM", "SWITCH", "RUN"
var data
var priority: int = 0

func _init(actor_ref: Monster, target_refs: Array, action_type: String, action_data = null):
	actor = actor_ref
	targets = target_refs
	type = action_type
	data = action_data
	
func execute() -> void:
	pass
