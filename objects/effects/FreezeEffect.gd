class_name FreezeEffect extends BattleEffect

@export_range(0.0, 1.0) var freeze_chance: float = 0.3

var name = "FREEZE"


func apply(actor_ref: Monster, target_ref: Monster, data_ref) -> void:
	super(actor_ref, target_ref, data_ref)
	animation_type = "TARGET"
	if randf() > freeze_chance:
		return
	
	if target.status:
		return
	
	target.status = BurnStatus.new()
	DialogueManager.show_dialogue("%s was frozen!" % target.name)
	await DialogueManager.dialogue_closed
