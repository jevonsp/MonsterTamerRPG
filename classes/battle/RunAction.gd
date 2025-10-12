class_name RunAction extends BattleAction

func _init(actor_ref: Monster, target_refs: Array) -> void:
	priority = 7
	super(actor_ref, target_refs, "RUN")
	
func execute() -> void:
	print("run attempt here")
