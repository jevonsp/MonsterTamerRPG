class_name GenericStatusContainer extends Resource

@export var name: String = ""
@export var components: Array[StatusComponent] = []

var should_continue_bool: bool

func apply_on_turn_start(monster: Monster) -> void:
	var context = {"name": name, "trigger": "turn_start"}
	var status_should_continue = await _apply_components(monster, "TURN_START", context)
	if not status_should_continue:
		_end_status(monster)
	
func apply_on_turn_end(monster: Monster) -> void:
	var context = {"name": name, "trigger": "turn_end"}
	var status_should_continue = await _apply_components(monster, "TURN_END", context)
	if not status_should_continue:
		_end_status(monster)

# For stacking statuses (monster.stacking_statuses)
func apply_stacking_on_turn_start(monster: Monster) -> bool:
	var context = {"name": name, "trigger": "turn_start"}
	return await _apply_components(monster, "TURN_START", context)
	
func apply_stacking_on_turn_end(monster: Monster) -> bool:
	var context = {"name": name, "trigger": "turn_end"}
	return await _apply_components(monster, "TURN_END", context)
	
func modify_stat(stat: String, base_value: float) -> float:
	var modified_value = base_value
	var context = {"name": name, "stat": stat, "base_value": base_value}
	
	for component in components:
		if component.trigger == "STAT_MOD":
			modified_value = component.modify_stat(stat, modified_value, context)
			
	return modified_value
	
func can_act(monster: Monster) -> bool:
	var can_act_result = true
	var context = {"name": name, "monster": monster}
	
	for component in components:
		if component.trigger == "CAN_ACT":
			@warning_ignore("redundant_await")
			can_act_result = can_act_result and await component.can_act(monster, context)
	
	return can_act_result
	
func _apply_components(monster: Monster, trigger_type: String, context: Dictionary) -> bool:
	var status_should_continue = true
	
	for component in components:
		if component.trigger == trigger_type:
			if component.can_apply(monster, context):
				@warning_ignore("redundant_await")
				var component_result = await component.apply(monster, context)
				status_should_continue = status_should_continue and component_result
			else:
				status_should_continue = false
				
			if not status_should_continue:
				break
				
	return status_should_continue
	
func _end_status(monster: Monster) -> void:
	monster.status = null
	DialogueManager.show_dialogue("%s's %s wore off!" % [monster.name, name])
	await DialogueManager.dialogue_closed
	
func should_continue() -> bool:
	for component in components:
		if component is DurationComponent:
			return component.should_continue()
	return true
