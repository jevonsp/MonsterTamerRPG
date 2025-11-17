class_name InfatuationEffect extends BattleEffect

@export_range(0.0, 1.0) var infatuation_chance: float = 0.3

var name = "CONFUSION"

func apply(actor_ref: Monster, target_ref: Monster, data_ref) -> void:
	super(actor_ref, target_ref, data_ref)
	animation_type = "TARGET"
	
	if randf() > infatuation_chance:
		return
	
	var infatuation_status = InfatuationStatus.new()
	target.stacking_statuses.append(infatuation_status)
	
	DialogueManager.show_dialogue("%s is in love!" % target.name)
	await DialogueManager.dialogue_closed
