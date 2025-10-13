class_name RunAction extends BattleAction

func _init(actor_ref: Monster, target_refs: Array) -> void:
	priority = 7
	super("RUN", null, actor_ref, target_refs)
	
func execute() -> void:
	print("run attempt here")
