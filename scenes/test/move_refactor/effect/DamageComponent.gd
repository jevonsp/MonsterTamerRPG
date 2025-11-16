class_name DamageComponent extends EffectComponent

@export var base_power: int = 40
@export_enum("PHYSICAL", "SPECIAL") var damage_category: String = "PHYSICAL"
@export var damage_self: bool = false
@export_range(0.0, 1.0) var self_damage_percentage: float = 0.0 # Percent based for recoil
@export var recoil_message: String = "{actor} was hurt by recoil."

#region TYPE CHART
const TYPE_CHART = {
	"FIRE": {
		"GRASS": 1.5,
		"WATER": 0.5,
		"LIGHT": 1.0,
		"DARK": 1.0
	},
	"GRASS": {
		"WATER": 1.5,
		"FIRE": 0.5,
		"LIGHT": 1.0,
		"DARK": 1.0
	},
	"WATER": {
		"FIRE": 1.5,
		"GRASS": 0.5,
		"LIGHT": 1.0,
		"DARK": 1.0
	},
	"LIGHT": {
		"DARK": 2.0,
		"FIRE": 1.0,
		"WATER": 1.0,
		"GRASS": 1.0
	},
	"DARK": {
		"LIGHT": 2.0,
		"FIRE": 1.0,
		"WATER": 1.0,
		"GRASS": 1.0
	},
	"NONE": {
		"FIRE": 1.0,
		"GRASS": 1.0,
		"WATER": 1.0,
		"LIGHT": 1.0,
		"DARK": 1.0,
	}
}
#endregion

func apply(actor: Monster, target: Monster, context: Dictionary) -> bool:
	var actual_target = actor if damage_self else target
	
	#print("==Damage.execute():==")
	#print("Actor Name: ", actor.name)
	#print("Actor: ", actor)
	#print("Actual Target Name: ", actual_target.name)
	#print("Actual Target: ", actual_target)
	
	var damage = calculate_damage(actor, actual_target, context)
	
	if damage_self and self_damage_percentage > 0:
		damage = int(actor.max_hitpoints * self_damage_percentage)
		await actual_target.take_damage(damage)
		var recoil_msg = recoil_message.format({"actor": actual_target.name})
		DialogueManager.show_dialogue(recoil_msg)
		await DialogueManager.dialogue_closed
		return true
	
	var message: String = "It dealt %s damage." % damage
	
	var move = context.get("move")
	var type_bonus = get_type_effectiveness(move.type if move else "NONE", target.type)
	
	if type_bonus < 1.0:
		message = "Its not very effective" + message
	if type_bonus > 1.0:
		message = "Super effective!" + message
	
	if randf() <= 0.0625:
		damage = damage * 2
		message = "Critical hit! " + message
	
	await actual_target.take_damage(damage)
	
	if damage_self:
		message = recoil_message.format({"actor": actual_target.name})
	
	DialogueManager.show_dialogue(message)
	await DialogueManager.dialogue_closed
	
	return true
	
func calculate_damage(actor, target, context) -> int:
	var atk: int = 0
	var def: int = 0
	match damage_category:
		"PHYSICAL":
			atk = actor.get_stat("attack")
			def = target.get_stat("defense")
		"SPECIAL":
			atk = actor.get_stat("special_attack")
			def = target.get_stat("special_defense")
	var move = context.get("move")
	var type_bonus = get_type_effectiveness(move.type if move else "NONE", target.type)
	
	var item_bonus: float = 1.0
	if actor.held_item:
		if actor.held_item.hold_effects:
			for effect in actor.held_item.hold_effects:
				if effect.boosted_type == move.type:
					item_bonus = effect.type_modifier
					break
	
	var stab_bonus: float = 1.5 if move and actor.type == move.type else 1.0
	
	var mods: float = type_bonus * item_bonus * stab_bonus
	var damage = int((((((2 * actor.level) / 5.0) + 2) * base_power * atk / float(def)) / 50.0) * mods)
	print("final damage: ", damage)
	return max(damage, 1)
	
func get_type_effectiveness(attacking_type: String, defending_type: String) -> float:
	attacking_type = attacking_type.to_upper()
	defending_type = defending_type.to_upper()
	return TYPE_CHART.get(attacking_type, {}).get(defending_type, 1.0)
