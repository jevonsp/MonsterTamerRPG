class_name SleepEffect extends BattleEffect

@export_range(0.0, 1.0) var sleep_chance: float = 0.3

var name = "SLEEP"


func apply(actor_ref: Monster, target_ref: Monster, data_ref) -> void:
	super(actor_ref, target_ref, data_ref)
	animation_type = "TARGET"
	if randf() > sleep_chance:
		return
	
	if target.status:
		return
	
	target.staus = BurnStatus.new()
	DialogueManager.show_dialogue("%s was put to sleep!" % target.name)
	await DialogueManager.dialogue_closed
