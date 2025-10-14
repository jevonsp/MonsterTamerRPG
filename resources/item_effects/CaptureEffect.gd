class_name CaptureEffect extends ItemEffect

@export var capture_bonus: float = 1.0

var name = "CAPTURE"

func apply(actor: Monster, target: Monster, item: Item) -> void:
	match item.target_type:
		"ENEMY":
			EventBus.effect_started.emit("CAPTURE", actor, target, item.sprite)
			var a = capture_chance(target)
			print("Modified capture rate (a): ", a)
			if a >= 1044480:
				print("Guaranteed capture!")
				EventBus.capture_shake.emit(1)
				target.attempt_capture(true)
				return
			var b = calculate_shake_threshold(a)
			var probability = (a / 1044480.0) ** 0.75
			print("Capture probability: ", snappedf(probability * 100, 0.01), "%")
			print("Shake threshold (b): ", b, " / 65536")
			
			var is_critical = get_critical_capture()
			
			if shake_check(is_critical, b):
				target.attempt_capture(true)
			else:
				target.attempt_capture(false)
			
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
	
func calculate_shake_threshold(capture_value: int) -> int:
	var ratio = capture_value / 1044480.0
	var fourth_root = pow(ratio, 0.25)
	return int(floor(65536.0 * fourth_root))
	
func shake_check(critical: bool, chance: int) -> bool:
	var shake_number = 1 if critical else 3
	for i in range(shake_number):
		var roll = randi() % 65536
		print("Shake ", i + 1, ": rolled ", roll, " vs ", chance, " - ", "SUCCESS" if roll < chance else "FAIL")
		if roll >= chance:
			EventBus.capture_shake.emit(i)
			return false
	EventBus.capture_shake.emit(shake_number)
	return true
	
func get_critical_capture() -> bool:
	return false
	
func get_status_bonus(_target: Monster) -> float:
	var status_bonus: float = 1.0
	return status_bonus
