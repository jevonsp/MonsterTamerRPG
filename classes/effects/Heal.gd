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
	print("(actor_ref): ", actor_ref, "(target_ref): ", target_ref)
	print("player_actor: ", BattleManager.player_actor, "enemy_actor: ", BattleManager.enemy_actor)
	print("health now: ", target_ref.hitpoints)
			
func _apply_heal() -> void:
	EventBus.effect_started.emit(target_type, actor, target, animation)
	await EventBus.effect_ended
	if revives and target.is_fainted:
		target.revive()
		print(target.name, " was revived by ", data.name)
	elif not target.is_fainted:
		await target.heal(heal_amount)
		print(
			"player used ",
			data.name,
			" to heal ",
			target.name,
			" for ",
			heal_amount,
			" HP")
