class_name MoveHealEffect extends MoveEffect

@export var heal_amount: int = 20
@export var revives: bool = false

func apply(actor: Monster, target: Monster, move: Move) -> void:
	match move.target_type:
		"SELF":
			_apply_heal(actor, target, move.name, move.sprite)
		"ALLY":
			_apply_heal(actor, target, move.name, move.sprite)
		"ENEMY":
			print(move.name, " has no healing effect on enemy target.")
		"ENEMIES":
			print(move.name, " has no healing effect on enemy targets.")
		"ALLIES":
			_apply_heal(actor, target, move.name, move.sprite)
		"ALL":
			print(move.name, " has no healing effect on all targets (if any are enemies).")
		_:
			print("Unhandled target_type in MoveHealEffect:", move.target_type)
			
func _apply_heal(actor: Monster, target: Monster, name: String, sprite: Texture2D) -> void:
	EventBus.effect_started.emit("HEAL", actor, target, sprite)
	if revives and target.is_fainted:
		target.revive()
		print(target.name, " was revived by ", name)
	elif not target.is_fainted:
		target.heal(heal_amount)
		print(actor.name, " healed ", target.name, " for ", heal_amount, " HP")
	print("(actor): ", actor)
	print("(target): ", target)
	print("player_actor: ", BattleManager.player_actor)
	print("enemy_actor: ", BattleManager.enemy_actor)
	print("health now: ", target.hitpoints)
