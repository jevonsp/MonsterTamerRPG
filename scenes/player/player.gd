extends CharacterBody2D

@export var anim_tree: AnimationTree
@export var ray2d: RayCast2D

enum PlayerState {IDLE, TURNING, WALKING}
var state = PlayerState.IDLE

enum FacingDirection {UP, DOWN, LEFT, RIGHT}
var facing = FacingDirection.DOWN

const TILE_SIZE = 16
var walk_speed = 5.0

var start_position: Vector2 = Vector2.ZERO
var move_direction: Vector2 = Vector2.ZERO
var input_direction: Vector2 = Vector2.ZERO
var is_moving: bool = false
var percent_moved: float = 0.0

# Direction key storage
var direction_keys: Array = []

@onready var anim_state = anim_tree.get("parameters/playback")
func _ready() -> void:
	add_to_group("player")
	start_position = position
		
func _on_animation_finished(anim_name: String):
	if anim_name == "Turn":
		finished_turning()
		
func _process(_delta: float) -> void:
	direction_storage()

func _physics_process(delta: float) -> void:
	if state == PlayerState.TURNING:
		var current_state = anim_state.get_current_node()
		if current_state == "Idle" or "Walk":
			finished_turning()
		return
	elif not is_moving:
		process_player_input()
		anim_state.travel("Idle")
	if is_moving:
		anim_state.travel("Walk")
		move(delta)
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("yes"):
		if ray2d.is_colliding():
			var collider = ray2d.get_collider()
			print("Ray hit:", collider)
			if collider.is_in_group("interactable"):
				print("tried to interact")
				print(collider.get_parent())
				collider.interact()
				
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
		anim_tree.set("parameters/Idle/blend_position", input_direction)
		anim_tree.set("parameters/Walk/blend_position", input_direction)
		anim_tree.set("parameters/Turn/blend_position", input_direction)
		
		if need_to_turn():
			state = PlayerState.TURNING
			anim_state.travel("Turn")
		else:
			start_position = position
			move_direction = input_direction
			is_moving = true
			state = PlayerState.WALKING
	else:
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
