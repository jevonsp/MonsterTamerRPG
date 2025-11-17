class_name Item2 extends Resource

@export var name: String = ""
@export var icon: Texture2D
@export var value: int = 100

@export_subgroup("Flags")
@export var in_battle_only: bool = true
@export var is_held: bool = false
@export var key_item: bool = false

@export_subgroup("Animation")
@export_enum("ACTOR", "TARGET", "THROWN", "CENTER") var animation_type = "CENTER"
@export var still: bool = false
@export var animation: PackedScene
@export var sprite: PackedScene

@export_subgroup("Target Type")
@export_enum("ENEMY", "ALLY") var target_type: String = "ENEMY"
@export var chooses_targets: bool = false

@export_subgroup("Effects")
@export var components: Array[EffectComponent] = []

@export_subgroup("Hold Effects")
@export_range(-7, 7) var priority: int = 0
@export var hold_effects: Array[HoldEffect] = []

@export_subgroup("Descriptions")
@export_multiline var short_description: String = ""
@export_multiline var long_description: String = ""

var miss_message: String = "It had no effect!"

func execute(actor: Monster, target: Monster) -> void:
	print("item execute")
	var in_battle: bool = BattleManager.in_battle
	
	var context = {
		"item": self,
		"battle_state": {
			"in_battle": in_battle,
			"accuracy_roll": true
		}
	}
	
	if in_battle and animation:
		EventBus.effect_started.emit(animation_type, actor, target, animation)
		await EventBus.effect_ended
	
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
