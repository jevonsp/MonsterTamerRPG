extends CharacterBody2D

@export var anim_tree: AnimationTree
@export var ray2d: RayCast2D

# State machine
enum State {IDLE, TURNING, WALKING}
var current_state = State.IDLE

# Facing direction
enum Direction {UP, DOWN, LEFT, RIGHT}
var facing_direction = Direction.DOWN

# Constants
const TILE_SIZE = 16
const WALK_SPEED = 5.0
const TURN_DURATION = 0.05

# Movement tracking
var tile_start_pos: Vector2 = Vector2.ZERO
var tile_target_pos: Vector2 = Vector2.ZERO
var move_progress: float = 0.0

# Input tracking
var held_keys: Array = []
var key_hold_times: Dictionary = {}  # Track how long each key has been held

# Turn timer
var turn_timer: float = 0.0

# Processing control
var processing: bool = true

@onready var anim_state = anim_tree.get("parameters/playback")

func _ready() -> void:
	add_to_group("player")
	tile_start_pos = position
	tile_target_pos = position
	
	# Initialize animation to match starting facing direction
	var blend_dir = vector_from_direction(facing_direction)
	anim_tree.set("parameters/Idle/blend_position", blend_dir)
	anim_tree.set("parameters/Turn/blend_position", blend_dir)
	anim_tree.set("parameters/Walk/blend_position", blend_dir)
	anim_state.travel("Idle")
	
	GameManager.input_state_changed.connect(_on_input_state_changed)
	
func _process(delta: float) -> void:
	update_held_keys(delta)
		
func _physics_process(delta: float) -> void:
	if not processing:
		return
		
	match current_state:
		State.IDLE:
			process_idle_state()
		State.TURNING:
			process_turning_state(delta)
		State.WALKING:
			process_walking_state(delta)

func _input(event: InputEvent) -> void:
	if not processing:
		return
	if event.is_action_pressed("yes"):
		attempt_interaction()

# ============================================================================
# STATE PROCESSING
# ============================================================================

func process_idle_state() -> void:
	var input_dir = get_input_direction()
	
	if input_dir != Vector2.ZERO:
		var new_facing = direction_from_vector(input_dir)
		
		# Check if we need to turn
		if new_facing != facing_direction:
			start_turning(new_facing)
		else:
			# Already facing correct direction, try to move
			attempt_movement(input_dir)

func process_turning_state(delta: float) -> void:
	turn_timer += delta
	
	var input_dir = get_input_direction()
	if input_dir != Vector2.ZERO:
		var input_facing = direction_from_vector(input_dir)
		if input_facing == facing_direction:
			# Only start moving if the key has been held longer than turn duration
			var last_key = held_keys.back() if not held_keys.is_empty() else ""
			if last_key in key_hold_times and key_hold_times[last_key] >= TURN_DURATION:
				# Key held long enough - start moving immediately
				if attempt_movement(input_dir):
					return  # Successfully started moving
	
	if turn_timer >= TURN_DURATION:
		# Turn complete - update idle blend position to match new facing
		var blend_dir = vector_from_direction(facing_direction)
		anim_tree.set("parameters/Idle/blend_position", blend_dir)
		
		current_state = State.IDLE
		anim_state.travel("Idle")

func process_walking_state(delta: float) -> void:
	move_progress += WALK_SPEED * delta
	
	if move_progress >= 1.0:
		position = tile_target_pos
		move_progress = 0.0
		EventBus.step_completed.emit(global_position)

		# Check for continued movement
		var input_dir = get_input_direction()
		if input_dir != Vector2.ZERO:
			var new_facing = direction_from_vector(input_dir)
			
			if new_facing != facing_direction:
				current_state = State.IDLE
				anim_state.travel("Idle")
				start_turning(new_facing)
			else:
				print("Continuing walk, attempting movement...")
				if not attempt_movement(input_dir):
					current_state = State.IDLE
					anim_state.travel("Idle")
		else:
			current_state = State.IDLE
			anim_state.travel("Idle")
	else:
		# Interpolate position
		position = tile_start_pos.lerp(tile_target_pos, move_progress)

# ============================================================================
# STATE TRANSITIONS
# ============================================================================

func start_turning(new_facing: Direction) -> void:
	var blend_dir = vector_from_direction(new_facing)
	
	# Update blend positions FIRST before changing anything
	anim_tree.set("parameters/Turn/blend_position", blend_dir)
	anim_tree.set("parameters/Idle/blend_position", blend_dir)
	anim_tree.set("parameters/Walk/blend_position", blend_dir)
	
	# Update facing direction
	facing_direction = new_facing
	
	# Update raycast to face new direction
	var ray_dir = vector_from_direction(new_facing)
	ray2d.target_position = ray_dir * TILE_SIZE / 2
	
	# Now change state and start animation
	current_state = State.TURNING
	turn_timer = 0.0
	
	# Travel to Turn animation
	anim_state.travel("Turn")

func attempt_movement(input_dir: Vector2) -> bool:
	# Check collision - raycast should be from current position
	ray2d.target_position = input_dir * TILE_SIZE / 2
	ray2d.force_raycast_update()
	
	print("Attempting move from: ", position, " in direction: ", input_dir)
	print("Raycast colliding: ", ray2d.is_colliding())
	if ray2d.is_colliding():
		print("Collider: ", ray2d.get_collider())
	
	if ray2d.is_colliding():
		# Blocked - return false but DON'T change state
		print("BLOCKED - returning false")
		return false
	
	# Start walking
	print("NOT BLOCKED - starting walk")
	tile_start_pos = position
	tile_target_pos = position + (input_dir * TILE_SIZE)
	move_progress = 0.0
	current_state = State.WALKING
	
	var blend_dir = input_dir
	anim_tree.set("parameters/Walk/blend_position", blend_dir)
	anim_state.travel("Walk")
	return true

# ============================================================================
# INPUT HANDLING
# ============================================================================

func update_held_keys(delta: float) -> void:
	var directions = ["up", "down", "right", "left"]
	
	for dir in directions:
		if Input.is_action_just_pressed(dir):
			held_keys.push_back(dir)
			key_hold_times[dir] = 0.0
		elif Input.is_action_just_released(dir):
			held_keys.erase(dir)
			key_hold_times.erase(dir)
		elif Input.is_action_pressed(dir) and dir in key_hold_times:
			# Increment hold time for keys currently being held
			key_hold_times[dir] += delta

func get_input_direction() -> Vector2:
	if held_keys.is_empty():
		return Vector2.ZERO
	
	var direction_map = {
		"up": Vector2(0, -1),
		"down": Vector2(0, 1),
		"left": Vector2(-1, 0),
		"right": Vector2(1, 0)
	}
	
	var key = held_keys.back()
	return direction_map.get(key, Vector2.ZERO)

func clear_inputs() -> void:
	held_keys.clear()
	key_hold_times.clear()
	current_state = State.IDLE
	move_progress = 0.0
	anim_state.travel("Idle")

# ============================================================================
# DIRECTION HELPERS
# ============================================================================

func direction_from_vector(vec: Vector2) -> Direction:
	if vec.x < 0:
		return Direction.LEFT
	elif vec.x > 0:
		return Direction.RIGHT
	elif vec.y < 0:
		return Direction.UP
	else:
		return Direction.DOWN

func vector_from_direction(dir: Direction) -> Vector2:
	match dir:
		Direction.UP: return Vector2(0, -1)
		Direction.DOWN: return Vector2(0, 1)
		Direction.LEFT: return Vector2(-1, 0)
		Direction.RIGHT: return Vector2(1, 0)
	return Vector2.ZERO

# ============================================================================
# INTERACTION
# ============================================================================

func attempt_interaction() -> void:
	if ray2d.is_colliding():
		var collider = ray2d.get_collider()
		if collider.is_in_group("interactable"):
			collider.interact()

# ============================================================================
# INPUT STATE MANAGEMENT
# ============================================================================

func _on_input_state_changed(new_state) -> void:
	match new_state:
		GameManager.InputState.OVERWORLD:
			processing = true
		GameManager.InputState.BATTLE:
			processing = false
		GameManager.InputState.DIALOGUE:
			processing = false
		GameManager.InputState.MENU:
			processing = false
		GameManager.InputState.INACTIVE:
			pass
