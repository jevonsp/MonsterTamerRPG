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
	print("apply heal called")
	DialogueManager.show_dialogue("%s was used on %s" % [data.name, target.name], true)
	await DialogueManager.dialogue_closed
	if BattleManager.in_battle:
		EventBus.effect_started.emit(target_type, actor, target, animation)
		await EventBus.effect_ended
	if revives and target.is_fainted:
		target.revive()
		DialogueManager.show_dialogue("%s was revived by its effect" % target.name)
		await DialogueManager.dialogue_closed
	if heal_amount > 0:
		print("healed monster for: ", heal_amount)
		await target.heal(heal_amount)
		DialogueManager.show_dialogue("%s was healed for %s by its effect" % [target.name, heal_amount], false)
		await DialogueManager.dialogue_closed
	if not BattleManager.in_battle:
		EventBus.party_effect_ended.emit()
