class_name BattleAction extends RefCounted

var actor: Monster = null
var targets: Array
var type: String # "MOVE", "ITEM", "SWITCH", "RUN"
var data
var priority: int = 0

func _init(action_type: String, action_data = null, actor_ref: Monster = null, target_refs: Array = []):
	type = action_type
	data = action_data
	actor = actor_ref
	targets = target_refs
	
func execute() -> void:
	pass
