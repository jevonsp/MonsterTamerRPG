class_name DurationComponent extends StatusComponent

@export var max_duration: int = 3
@export_range(0.0, 1.0) var breakout_chance: float = 0.0
@export var on_breakout_failed: StatusComponent

var turns_active: int = 0
var _should_end: bool = false
var _has_been_applied: bool = false

func apply(_monster: Monster, _context: Dictionary) -> bool:
	# Only reset on the VERY first application, not every time can_apply is called
	if not _has_been_applied:
		turns_active = 0
		_should_end = false
		_has_been_applied = true
		print("DEBUG: DurationComponent INITIALIZED - turns_active: ", turns_active, " max_duration: ", max_duration)
	else:
		print("DEBUG: DurationComponent REAPPLIED (ignoring reset)")
	return true

func can_apply(monster: Monster, context: Dictionary) -> bool:
	if _should_end:
		print("DEBUG: DurationComponent - already marked to end")
		return false
		
	turns_active += 1
	print("DEBUG: DurationComponent - turn ", turns_active, "/", max_duration, " breakout_chance: ", breakout_chance)
		
	# Max duration reached - status ends
	if turns_active >= max_duration:
		print("DEBUG: DurationComponent - max duration reached, ending status")
		_should_end = true
		return false
	
	# Early breakout chance (skip on first turn)
	if breakout_chance > 0 and randf() <= breakout_chance:
		print("DEBUG: DurationComponent - early breakout successful!")
		_should_end = true
		return false
	else:
		print("DEBUG: DurationComponent - breakout failed or no breakout chance")
	
	# Status continues - apply failure behavior
	if on_breakout_failed:
		print("DEBUG: DurationComponent - applying on_breakout_failed: ", on_breakout_failed.get_class())
		# For ActionReplacementComponent, we don't apply it here, it handles itself in can_act
		# For other components, apply them normally
		if not (on_breakout_failed is ActionReplacementComponent):
			if on_breakout_failed.can_apply(monster, context):
				@warning_ignore("redundant_await")
				return await on_breakout_failed.apply(monster, context)
	
	print("DEBUG: DurationComponent - status continues")
	return true  # Status continues

func should_continue() -> bool:
	print("DEBUG: DurationComponent should_continue: ", not _should_end)
	return not _should_end
	
func reset_for_new_application():
	turns_active = 0
	_should_end = false
	_has_been_applied = false
	print("DEBUG: DurationComponent RESET for new application")
