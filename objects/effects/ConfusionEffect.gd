class_name ConfusionEffect extends BattleEffect

@export_range(0.0, 1.0) var confusion_chance: float = 0.3

var name = "CONFUSION"

func apply(actor_ref: Monster, target_ref: Monster, data_ref) -> void:
	super(actor_ref, target_ref, data_ref)
	animation_type = "TARGET"
	
	if randf() > confusion_chance:
		return
	
	var confusion_status = ConfusionStatus.new()
	target.stacking_statuses.append(confusion_status)
	
	DialogueManager.show_dialogue("%s is now confused!" % target.name)
	await DialogueManager.dialogue_closed
