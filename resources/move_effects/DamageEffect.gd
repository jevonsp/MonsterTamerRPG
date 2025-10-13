class_name DamageEffect extends MoveEffect

@export var base_power: int = 40

func apply(actor: Monster, target: Monster, move: Move) -> void:
	match move.target_type:
		"ENEMY":
			EventBus.effect_started.emit("DAMAGE", actor, target, move.sprite)
			var damage = calculate_damage(actor, target, move)
			target.take_damage(damage)
			print(actor.name, " dealt ", damage, " to ", target.name)
	print("(actor): ", actor)
	print("(target): ", target)
	print("player_actor: ", BattleManager.player_actor)
	print("enemy_actor: ", BattleManager.enemy_actor)
	print("health now: ", target.hitpoints)
	
func calculate_damage(actor: Monster, target: Monster, move: Move) -> int:
	var a: int = 0
	var d: int = 0
	match move.damage_category:
		"PHYSICAL":
			a = actor.attack
			d = target.defense
		"SPECIAL":
			a = actor.special_attack
			d = target.special_defense
	var MODIFIERS: float = 1.0
	var damage = int((((((2 * actor.level) / 5.0) + 2) * base_power * a / float(d)) / 50.0) * MODIFIERS)
	return damage
