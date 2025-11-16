class_name GenericStatusContainer extends Resource

@export var name: String = ""
@export var components: Array[StatusComponent] = []

var should_continue_bool: bool

func apply_on_turn_start(monster: Monster) -> void:
	print("DEBUG: GenericStatusContainer.apply_on_turn_start - ", name)
	var context = {"name": name, "trigger": "turn_start"}
	var status_should_continue = await _apply_components(monster, "TURN_START", context)
	print("DEBUG: GenericStatusContainer.apply_on_turn_start - status_should_continue: ", status_should_continue)
	if not status_should_continue:
		_end_status(monster)
	
func apply_on_turn_end(monster: Monster) -> void:
	print("DEBUG: GenericStatusContainer.apply_on_turn_end - ", name)
	var context = {"name": name, "trigger": "turn_end"}
	var status_should_continue = await _apply_components(monster, "TURN_END", context)
	print("DEBUG: GenericStatusContainer.apply_on_turn_end - status_should_continue: ", status_should_continue)
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
	print("DEBUG: GenericStatusContainer._apply_components - ", name, " trigger: ", trigger_type)
	var status_should_continue = true
	
	for component in components:
		if component.trigger == trigger_type:
			print("DEBUG: GenericStatusContainer - checking component: ", component.get_class())
			if component.can_apply(monster, context):
				print("DEBUG: GenericStatusContainer - applying component: ", component.get_class())
				@warning_ignore("redundant_await")
				var component_result = await component.apply(monster, context)
				status_should_continue = status_should_continue and component_result
				print("DEBUG: GenericStatusContainer - component_result: ", component_result)
			else:
				# If any component fails can_apply, the status might end
				print("DEBUG: GenericStatusContainer - component failed can_apply")
				status_should_continue = false
				
			if not status_should_continue:
				print("DEBUG: GenericStatusContainer - breaking due to status_should_continue: false")
				break
				
	print("DEBUG: GenericStatusContainer._apply_components - final status_should_continue: ", status_should_continue)
	return status_should_continue

func _end_status(monster: Monster) -> void:
	monster.status = null
	DialogueManager.show_dialogue("%s's %s wore off!" % [monster.name, name])
	await DialogueManager.dialogue_closed

# Helper method for BattleManager to check if stacking status should continue
func should_continue() -> bool:
	# For stacking statuses, check if any DurationComponent wants to end
	for component in components:
		if component is DurationComponent:
			return component.should_continue()
	# If no DurationComponent, status continues
	return true
