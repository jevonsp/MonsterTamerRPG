class_name MoveAction extends BattleAction

var move: Move

func _init(actor_ref: Monster, target_refs: Array[Monster], move_data: Move):
	move = move_data
	priority = move.priority
	super(actor_ref, target_refs, "MOVE", move_data)
	
func execute() -> void:
	for t in targets:
		if t and t.hitpoints > 0:
			for effects in data.effects:
				_execute_effect(t, effects)
				await EventBus.effect_ended
		
func _execute_effect(target: Monster, effect: Effect):
	match effect.type:
		"DAMAGE":
			EventBus.effect_started.emit("DAMAGE", actor, target, move.sprite)
			var damage = calculate_damage(target, effect)
			target.take_damage(damage)
			print(actor.name, " dealt ", damage, " to ", target.name)
			EventBus.effect_ended.emit()
		"HEAL": pass
			
func calculate_damage(t: Monster, e: Effect) -> int:
	var a: int = 0
	var d: int = 0
	match move.damage_category:
		"PHYSICAL":
			a = actor.attack
			d = t.defense
		"SPECIAL":
			a = actor.special_attack
			d = t.special_defense
	var MODIFIERS: float = 1.0
	var damage = int((((((2 * actor.level) / 5.0) + 2) * e.base_power * a / float(d)) / 50.0) * MODIFIERS)
	return damage
