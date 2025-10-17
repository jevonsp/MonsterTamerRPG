extends CharacterBody2D

@export var anim_tree: AnimationTree
@export var ray2d: RayCast2D

enum PlayerState {IDLE, TURN, WALK}
var state = PlayerState.IDLE

enum FacingDirection {UP, DOWN, LEFT, RIGHT}
var facing = FacingDirection.DOWN

const TILE_SIZE = 16
var walk_speed = 5.0

var start_position: Vector2 = Vector2.ZERO
var move_direction: Vector2 = Vector2.ZERO
var input_direction: Vector2 = Vector2.ZERO
var direction_keys: Array = []
var is_moving: bool = false
var percent_moved: float = 0.0

var processing: bool = true
var animating: bool = false

@onready var anim_state = anim_tree.get("parameters/playback")

func _ready() -> void:
	add_to_group("player")
	start_position = position
	EventBus.toggle_player.connect(_on_toggle_player)
	GameManager.input_state_changed.connect(_on_input_state_changed)
	
func _process(_delta: float) -> void:
	direction_storage()
		
func _physics_process(delta: float) -> void:
	if not processing:
		return
	if state == PlayerState.TURN:
		var current_state = anim_state.get_current_node()
		if current_state == "Idle":
			finished_turning()
			animating = false
		return
	elif not is_moving:
		process_player_input()
		anim_state.travel("Idle")
		animating = false
	elif is_moving:
		if not animating:
			anim_state.travel("Walk")
			animating = true
		move(delta)
		
func _input(event: InputEvent) -> void:
	if not processing:
		return
	if event.is_action_pressed("yes"):
		if ray2d.is_colliding():
			var collider = ray2d.get_collider()
			print("Ray hit:", collider)
			if collider.is_in_group("interactable"):
				print("tried to interact")
				print(collider.get_parent())
				collider.interact()
				
func _on_input_state_changed(new_state):
	match new_state:
		GameManager.InputState.OVERWORLD:
			_on_toggle_player()
		GameManager.InputState.BATTLE:
			_on_toggle_player()
		GameManager.InputState.DIALOGUE:
			_on_toggle_player()
		GameManager.InputState.MENU:
			_on_toggle_player()
		GameManager.InputState.INACTIVE: pass
				
func _on_toggle_player():
	processing = !processing
	clear_inputs()
	
func set_anim_tree() -> void:
	anim_tree.set("parameters/Idle/blend_position", input_direction)
	anim_tree.set("parameters/Walk/blend_position", input_direction)
	anim_tree.set("parameters/Turn/blend_position", input_direction)
	
func _on_animation_finished(anim_name: String):
	if anim_name == "Turn":
		finished_turning()
		
func is_state_playing(anim: String) -> bool:
	return anim_state.get_current_node() == anim
		
# Handles key press/release tracking
func direction_storage():
	var directions = ["up", "down", "right", "left"]
	
	for dir in directions:
		if Input.is_action_just_pressed(dir):
			direction_keys.push_back(dir)
		elif Input.is_action_just_released(dir):
			direction_keys.erase(dir)
			
	# Clear array if empty
	if direction_keys.size() == 0:
		direction_keys.clear()
		
func clear_inputs() -> void:
	direction_keys.clear()
	input_direction = Vector2.ZERO
	is_moving = false
	move_direction = Vector2.ZERO
	state = PlayerState.IDLE
	anim_state.travel("Idle")
	percent_moved = 0.0
	
# Converts stored keys into a movement direction
func process_player_input():
	var direction_map = {
		"up": Vector2(0, -1),
		"down": Vector2(0, 1),
		"left": Vector2(-1, 0),
		"right": Vector2(1, 0)}
	
	if direction_keys.size() > 0:
		var key = direction_keys.back()
		input_direction = direction_map.get(key, Vector2.ZERO)
	else:
		input_direction = Vector2.ZERO
		
	# Only start moving if a direction is pressed
	if input_direction != Vector2.ZERO:
		if need_to_turn():
			# Set blend positions when turning
			anim_tree.set("parameters/Idle/blend_position", input_direction)
			anim_tree.set("parameters/Walk/blend_position", input_direction)
			anim_tree.set("parameters/Turn/blend_position", input_direction)
			state = PlayerState.TURN
			anim_state.travel("Turn")
		else:
			# Set blend positions only when starting a new walk
			anim_tree.set("parameters/Idle/blend_position", input_direction)
			anim_tree.set("parameters/Walk/blend_position", input_direction)
			anim_tree.set("parameters/Turn/blend_position", input_direction)
			start_position = position
			move_direction = input_direction
			is_moving = true
			state = PlayerState.WALK
	else:
		state = PlayerState.IDLE
		anim_state.travel("Idle")
		
# Handles turning based on new input
func need_to_turn() -> bool:
	var new_facing
	
	if input_direction.x < 0:
		new_facing = FacingDirection.LEFT
	elif input_direction.x > 0:
		new_facing = FacingDirection.RIGHT
	elif input_direction.y < 0:
		new_facing = FacingDirection.UP
	elif input_direction.y > 0:
		new_facing = FacingDirection.DOWN
		
	if facing != new_facing:
		facing = new_facing
		return true
	return false
	
func finished_turning() -> void:
	state = PlayerState.IDLE
	
# Moves the player one tile at a time
func move(delta: float):
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	ray2d.target_position = desired_step
	ray2d.force_raycast_update()
	
	if not ray2d.is_colliding():
		percent_moved += walk_speed * delta
		if percent_moved >= 1.0:
			position = start_position + move_direction * TILE_SIZE
			percent_moved = 0.0
			is_moving = false
			move_direction = Vector2.ZERO
			state = PlayerState.IDLE
			EventBus.step_completed.emit(global_position)
		else:
			position = start_position + move_direction * TILE_SIZE * percent_moved
	else:
		is_moving = false
