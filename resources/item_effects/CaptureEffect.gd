class_name CaptureEffect extends ItemEffect

@export var capture_bonus: float = 1.0

var name = "CAPTURE"

func apply(actor: Monster, target: Monster, item: Item) -> void:
	match item.target_type:
		"ENEMY":
			EventBus.effect_started.emit("THROWN", actor, target, item.sprite)
			var a = capture_chance(target)
			print("Modified capture rate (a): ", a)
			if a >= 1044480:
				print("Guaranteed capture!")
				await target.attempt_capture(1044480, true)
				return
			await target.attempt_capture(a, false)
			
			print(actor.name, " attempted to capture ", target.name, " with ", item.name)
			
func capture_chance(target: Monster) -> int:
	var max_hp = target.max_hitpoints
	var current_hp = target.hitpoints
	var monster_rate = target.capture_rate
	var status_bonus: float = get_status_bonus(target)
	var hp_value = ((3 * max_hp - 2 * current_hp) / (3.0 * max_hp))
	var pre_status = floor(hp_value * 4096 * monster_rate * capture_bonus)
	var capture_value = int(pre_status * status_bonus)
	return capture_value
	
func get_status_bonus(_target: Monster) -> float:
	var status_bonus: float = 1.0
	return status_bonus
