class_name CaptureComponent extends EffectComponent

@export var capture_bonus: float = 1.0
@export var capture_message: String = "Threw {item} at {target}!"

func apply(actor: Monster, target: Monster, context: Dictionary) -> bool:
	var item = context.get("item")
	var anim = item.animation if not item.still else item.sprite
	
	
	
	if capture_message != "":
		var message = capture_message.format({"item": item.name, "target": target.name})
		DialogueManager.show_dialogue(message, true)
		await DialogueManager.dialogue_closed
		
	EventBus.effect_started.emit(item.animation_type, actor, target, anim)
	await EventBus.effect_ended
	
	var capture_value = _calculate_capture_chance(target)
	
	if capture_value >= 1044480: # Critical Capture
		await target.attempt_capture(1044480, true)
	else:
		await target.attempt_capture(capture_value, false)
	
	return true
	
func _calculate_capture_chance(target: Monster) -> int:
	var max_hp = target.max_hitpoints
	var current_hp = target.hitpoints
	var monster_rate = target.capture_rate
	
	var hp_value = ((3 * max_hp - 2 * current_hp) / (3.0 * max_hp))
	var pre_status = floor(hp_value * 4096 * monster_rate * capture_bonus)
	var status_bonus = _get_status_bonus(target)
	var capture_value = int(pre_status * status_bonus)
	
	return capture_value
	
func _get_status_bonus(target: Monster) -> float:
	# Status effects that improve capture rate
	if target.status:
		match target.status.name:
			"PARALYZE", "BURN", "POISON":
				return 1.5
			"SLEEP", "FREEZE":
				return 2.0
	return 1.0
