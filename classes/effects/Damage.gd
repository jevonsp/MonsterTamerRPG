class_name Damage extends BattleEffect

@export var base_power: int = 40

@export_subgroup("Damage Category")
@export_enum("PHYSICAL", "SPECIAL") var damage_category: String = "PHYSICAL"

var name = "DAMAGE"

func apply(actor_ref: Monster, target_ref: Monster, move_ref) -> void:
	super(actor_ref, target_ref, move_ref)
	match target_type:
		"ENEMY":
			DialogueManager.show_dialogue("%s used %s!" % [actor.name, move_ref.name], true)
			EventBus.effect_started.emit(animation_type, actor_ref, target_ref, animation)
			await EventBus.effect_ended
			var damage = calculate_damage()
			await target_ref.take_damage(damage)
			DialogueManager.show_dialogue("It dealt %s to %s!" % [damage, target.name], false)
			await DialogueManager.dialogue_closed
	
func calculate_damage() -> int:
	var atk: int = 0
	var def: int = 0
	match damage_category:
		"PHYSICAL":
			atk = actor.get_stat("attack")
			def = target.get_stat("defense")
		"SPECIAL":
			atk = actor.get_stat("special_attack")
			def = target.get_stat("special_defense")
	var MODIFIERS: float = 1.0
	var damage = int((((((2 * actor.level) / 5.0) + 2) * base_power * atk / float(def)) / 50.0) * MODIFIERS)
	return damage
