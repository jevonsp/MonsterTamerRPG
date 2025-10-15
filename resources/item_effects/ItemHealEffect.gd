class_name ItemHealEffect extends ItemEffect

@export var heal_amount: int = 20
@export var revives: bool = false

var name = "ITEM_HEAL"

func apply(actor: Monster, target: Monster, item: Item) -> void:
	match item.target_type:
		"SELF":
			_apply_heal(actor, target, item)
		"ALLY":
			_apply_heal(actor, target, item)
		"ENEMY":
			print(item.name, " has no healing effect on enemy target.")
		"ENEMIES":
			print(item.name, " has no healing effect on enemy targets.")
		"ALLIES":
			_apply_heal(actor, target, item)
		"ALL":
			print(item.name, " has no healing effect on all targets (if any are enemies).")
		_:
			print("Unhandled target_type in ItemHealEffect:", item.target_type)
			
func _apply_heal(actor: Monster, target: Monster, item: Item) -> void:
	EventBus.effect_started.emit(item.target_type, actor, target, item.animation)
	if revives and target.is_fainted:
		target.revive()
		print(target.name, " was revived by ", item.name)
	elif not target.is_fainted:
		target.heal_damage(heal_amount)
		print("player used ", item.name, " to heal ", target.name, " for ", heal_amount, " HP")
	print("(actor): ", actor, "(target): ", target)
	print("player_actor: ", BattleManager.player_actor, "enemy_actor: ", BattleManager.enemy_actor)
	print("health now: ", target.hitpoints)
