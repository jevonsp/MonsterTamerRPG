class_name CaptureEffect extends ItemEffect

@export var capture_bonus: float = 1.0

func apply(actor: Monster, target: Monster, item: Item) -> void:
	match item.target_type:
		"ENEMY":
			EventBus.effect_started.emit("CAPTURE", actor, target, item.sprite)
			var chance = capture_chance(target)
			print(actor.name, " attempted to capture ", target.name, " with ", item.name)
			target.attempt_capture(chance)
			print("Capture chance:", chance)
	print("(actor): ", actor)
	print("(target): ", target)
	print("player_actor: ", BattleManager.player_actor)
	print("enemy_actor: ", BattleManager.enemy_actor)
	print("health now: ", target.hitpoints)
	
func capture_chance(target: Monster) -> int:
	var max_hp = target.max_hitpoints
	var current_hp = target.hitpoints
	var monster_rate = target.capture_rate
	var status_bonus: float = 1.0
	
	var hp_value = ((3 * max_hp - 2 * current_hp) / (3.0 * max_hp))
	var capture_value = int(hp_value * 4096 * monster_rate * capture_bonus * status_bonus)
	
	return capture_value
