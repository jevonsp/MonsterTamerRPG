class_name DurationComponent extends StatusComponent

@export var max_duration: int = 3
@export_range(0.0, 1.0) var breakout_chance: float = 0.0
@export var on_breakout_failed: StatusComponent

var turns_active: int = 0
var _should_end: bool = false
var _has_been_applied: bool = false

func apply(_monster: Monster, _context: Dictionary) -> bool:
	
	if not _has_been_applied:
		turns_active = 0
		_should_end = false
		_has_been_applied = true
	return true

func can_apply(monster: Monster, context: Dictionary) -> bool:
	if _should_end:
		return false
		
	turns_active += 1
		
	if turns_active >= max_duration:
		_should_end = true
		return false
	
	if breakout_chance > 0 and randf() <= breakout_chance:
		_should_end = true
		return false
	
	if on_breakout_failed:
		if not (on_breakout_failed is ActionReplacementComponent):
			if on_breakout_failed.can_apply(monster, context):
				@warning_ignore("redundant_await")
				return await on_breakout_failed.apply(monster, context)
	return true

func should_continue() -> bool:
	return not _should_end
	
func reset_for_new_application():
	turns_active = 0
	_should_end = false
	_has_been_applied = false
