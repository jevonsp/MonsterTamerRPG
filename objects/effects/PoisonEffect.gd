class_name PoisonEffect extends BattleEffect

@export_range(0.0, 1.0) var poison_chance: float = 0.3

var name = "POISON"


func apply(actor_ref: Monster, target_ref: Monster, data_ref) -> void:
	super(actor_ref, target_ref, data_ref)
	animation_type = "TARGET"
	if randf() > poison_chance:
		return
	
	if target.status:
		return
	
	target.status = BurnStatus.new()
	DialogueManager.show_dialogue("%s was poisoned!" % target.name)
	await DialogueManager.dialogue_closed
