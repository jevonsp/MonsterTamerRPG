class_name Capture extends BattleEffect

@export var capture_bonus: float = 1.0

var name = "CAPTURE"

func apply(actor_ref: Monster, target_ref: Monster, item_ref) -> void:
	super(actor_ref, target_ref, item_ref)
	
	match target_type:
		"ENEMY":
			EventBus.effect_started.emit(target_type, actor, target, sprite)
			await EventBus.effect_ended
			
			var a = capture_chance()
			if a >= 1044480:
				await target.attempt_capture(1044480, true)
			else:
				await target.attempt_capture(a, false)
			
			print(actor_ref.name, " attempted to capture ", target_ref.name, " with ", item_ref.name)
		_:
			print("Unsupported target_type in Capture: ", target_type)
	
	print("(actor_ref): ", actor_ref, "(target_ref): ", target_ref)
	print("player_actor: ", BattleManager.player_actor, "enemy_actor: ", BattleManager.enemy_actor)
			
func capture_chance() -> int:
	var max_hp = target.max_hitpoints
	var current_hp = target.hitpoints
	var monster_rate = target.capture_rate
	var status_bonus: float = get_status_bonus(target)
	
	var hp_value = ((3 * max_hp - 2 * current_hp) / (3.0 * max_hp))
	var pre_status = floor(hp_value * 4096 * monster_rate * capture_bonus)
	var capture_value = int(pre_status * status_bonus)
	
	return capture_value
	
func get_status_bonus(_target: Monster) -> float:
	return 1.0
