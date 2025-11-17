class_name Move2 extends Resource

@export var name: String = ""
@export_enum("FIRE", "WATER", "GRASS", "LIGHT", "DARK", "NONE") var type = "NONE"
@export var components: Array[EffectComponent] = []
@export var accuracy: int = 100
@export var max_pp: int = 10
@export_range(-7, 7) var priority: int = 0
@export_multiline var description: String = ""

@export_subgroup("Target Type")
@export_enum("ENEMY", "ALLY") var target_type: String = "ENEMY"
@export var chooses_targets: bool = false

var miss_message: String = "{actor} missed!"

func execute(actor: Monster, target: Monster) -> void:
	var actor_accuracy_multi = actor._get_stage_multi(actor.stat_stages["accuracy"])
	var target_evasion_multi = target._get_stage_multi(target.stat_stages["evasion"])
	var accuracy_chance = (accuracy * actor_accuracy_multi * target_evasion_multi) / 100.0
	var accuracy_roll = randf() <= accuracy_chance
	
	var in_battle: bool = BattleManager.in_battle
	
	var context = {
		"move": self,
		"battle_state": {
			"in_battle": in_battle,
			"accuracy_roll": accuracy_roll
		}
	}
	
	var message = miss_message.format({
		"actor": actor.name
	})
	
	if not accuracy_roll:
		DialogueManager.show_dialogue(message)
		await DialogueManager.dialogue_closed
		return
		
	var skip_next: bool = false
		
	for component in components:
		if skip_next:
			skip_next = false
			continue
			
		@warning_ignore("redundant_await")
		if await component.can_apply(actor, target, context):
			@warning_ignore("redundant_await")
			await component.apply(actor, target, context)
			if component is ChanceComponent and component.should_skip_next:
				skip_next = true

func get_move_power() -> String:
	for component in components:
		if component is DamageComponent:
			return str(component.base_power)
	return "-"
	
func get_move_damage_category() -> String:
	for component in components:
		if component is DamageComponent:
			return component.damage_category
	return "-"
