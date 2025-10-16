class_name Heal extends BattleEffect

@export var heal_amount: int = 20
@export var revives: bool = false

var name = "HEAL"

func apply(actor_ref: Monster, target_ref: Monster, data_ref) -> void:
	super(actor_ref, target_ref, data_ref)
	match target_type:
		"SELF", "ALLY", "ALLIES":
			await _apply_heal()
		"ENEMY":
			print(data.name, " has no healing effect on enemy target.")
		"ENEMIES":
			print(data.name, " has no healing effect on enemy targets.")
		"ALL":
			print(data.name, " has no healing effect on all targets (if any are enemies).")
		_:
			print("Unhandled target_type in Heal: ", target_type)
			
func _apply_heal() -> void:
	DialogueManager.show_dialogue("%s was used on %s" % [data.name, target.name], true)
	EventBus.effect_started.emit(target_type, actor, target, animation)
	await EventBus.effect_ended
	if revives and target.is_fainted:
		target.revive()
		DialogueManager.show_dialogue("%s was revived by its effect" % target.name)
		await DialogueManager.dialogue_closed
	elif not target.is_fainted:
		await target.heal(heal_amount)
		DialogueManager.show_dialogue("%s was healed for %s by its effect" % [target.name, heal_amount])
		await DialogueManager.dialogue_closed
