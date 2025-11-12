class_name Damage extends BattleEffect

@export var base_power: int = 40

@export_subgroup("Damage Category")
@export_enum("PHYSICAL", "SPECIAL") var damage_category: String = "PHYSICAL"

var name = "DAMAGE"

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

func apply(actor_ref: Monster, target_ref: Monster, move_ref) -> void:
	super(actor_ref, target_ref, move_ref)
	match target_type:
		"ENEMY":
			if BattleManager.in_battle:
				EventBus.effect_started.emit(animation_type, actor_ref, target_ref, animation)
				await EventBus.effect_ended
			
			var damage = calculate_damage()
			
			if randf() <= 0.0625:
				var crit_damage = damage * 2
				await target_ref.take_damage(crit_damage)
				DialogueManager.show_dialogue("Critical hit!. \n
				%s dealt %s to %s!" % [move_ref.name, crit_damage, target.name], false)
				await DialogueManager.dialogue_closed
				return
			await target_ref.take_damage(damage)
			DialogueManager.show_dialogue("%s dealt %s to %s!" % [move_ref.name, damage, target.name], false)
			await DialogueManager.dialogue_closed
	if not BattleManager.in_battle:
		EventBus.party_effect_ended.emit()
	
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
	var type_bonus = get_type_effectiveness(data.type, target.type)
	var item_bonus: float = 1.0
	print("Actor held item: ", actor.held_item)
	if actor.held_item:
		print("Hold effects: ", actor.held_item.hold_effects)
		print("Hold effects count: ", actor.held_item.hold_effects.size())
		if actor.held_item.hold_effects:
			for effect in actor.held_item.hold_effects:
				print("Checking effect Boosted type: '", effect.boosted_type, "' Move type: '", data.type, "'")
				if effect.boosted_type == data.type:
					print("type matched: ", effect.type_modifier)
					item_bonus = effect.type_modifier
					break
	print("item bonus: ", item_bonus)
	var stab_bonus: float = 1.0
	if data.type == "NONE":
		pass
	else:
		if actor.type == data.type:
			stab_bonus = 1.5
	var mods: float = type_bonus * item_bonus * stab_bonus
	var damage = int((((((2 * actor.level) / 5.0) + 2) * base_power * atk / float(def)) / 50.0) * mods)
	print("final damage: ", damage)
	return max(damage, 1)
	
func get_type_effectiveness(attacking_type: String, defending_type: String) -> float:
	attacking_type = attacking_type.to_upper()
	defending_type = defending_type.to_upper() 
	print("type_effectiveness: ", TYPE_CHART.get(attacking_type, {}).get(defending_type, 1.0))
	return TYPE_CHART.get(attacking_type, {}).get(defending_type, 1.0)
