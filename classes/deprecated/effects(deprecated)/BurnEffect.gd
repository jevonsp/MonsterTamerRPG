class_name BurnEffect extends BattleEffect

@export_range(0.0, 1.0) var burn_chance: float = 0.3

var name = "BURN"

func apply(actor_ref: Monster, target_ref: Monster, data_ref) -> void:
	super(actor_ref, target_ref, data_ref)
	animation_type = "TARGET"
	
	if randf() > burn_chance:
		return
	
	if target.status:
		return
	
	target.status = BurnStatus.new()
	
	DialogueManager.show_dialogue("%s was burned!" % target.name)
	await DialogueManager.dialogue_closed
