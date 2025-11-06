class_name NPC extends Area2D

enum Direction {UP, DOWN, LEFT, RIGHT}
const TILE_SIZE: int = 16
const WALK_SPEED: float = 3.0
@export var npc_name: String = ""
@export var facing_direction: Direction = Direction.DOWN

@export_subgroup("Dialogue")
@export var dialogue: String = ""
@export var dialogues: Array[String] = []

@export_subgroup("Nodes")
@export var sprite: AnimatedSprite2D
@export var ray2d: RayCast2D

func _ready() -> void:
	setup_sprite()
	
func setup_sprite():
	if not sprite:
		return
	
	update_idle_animation()
	
func interact(interactor = null) -> void:
	turn_towards(interactor)
	await get_tree().create_timer(0.1).timeout
	if dialogues.is_empty():
		say_dialogue()
	else:
		for line in dialogues:
			await say_dialogue(line)
			
func turn_towards(interactor: CharacterBody2D) -> void:
	var dir = (interactor.global_position - global_position).normalized()
	if dir == vector_from_direction(facing_direction):
		return
	facing_direction = direction_from_vector(dir)
	update_turning_animation()
	
## Walks to the player. Takes a CharacterBody2D
func walk_to(interactor: CharacterBody2D) -> void:
	var stop_offset = vector_from_direction(facing_direction) * TILE_SIZE
	var grid_target: Vector2 = snap_to_grid(interactor.global_position) - stop_offset
	
	if global_position.distance_to(grid_target) < 1.0:
		return
	
	await walk_to_tile(grid_target)
	
## Walks a path of relative movements, (0, 1) -> (1, 0) etc
func walk_path(path: Array[Vector2]) -> void:
	for move in path:
		var target_tile: Vector2 = global_position + (move * TILE_SIZE)
		await walk_to_tile(target_tile)
	
func walk_to_tile(target_tile: Vector2) -> void:
	var start_tile: Vector2 = global_position
	var dir: Vector2 = (target_tile - start_tile).normalized()
	
	var pixels_to_move = start_tile.distance_to(target_tile)
	var pixels_per_second = WALK_SPEED * TILE_SIZE
	var duration = pixels_to_move / pixels_per_second
	var elapsed: float = 0.0
	facing_direction = direction_from_vector(dir)
	update_walking_animation()
	while elapsed < duration:
		elapsed += get_process_delta_time()
		var prog = min(elapsed / duration, 1.0)
		var new_pos = start_tile.lerp(target_tile, prog)
		global_position = Vector2(round(new_pos.x), round(new_pos.y))
		await get_tree().process_frame
	
	update_idle_animation()
	
func update_idle_animation():
	var dir = vector_from_direction(facing_direction)
	match dir:
		Vector2.DOWN: 
			sprite.play("TurnDown")
		Vector2.UP:
			sprite.play("TurnUp")
		Vector2.LEFT:
			sprite.flip_h = false
			sprite.play("TurnLeft")
		Vector2.RIGHT:
			sprite.flip_h = true
			sprite.play("TurnLeft")
	
func update_walking_animation():
	var dir = vector_from_direction(facing_direction)
	match dir:
		Vector2.DOWN: 
			sprite.play("WalkDown")
		Vector2.UP:
			sprite.play("WalkUp")
		Vector2.LEFT:
			sprite.flip_h = false
			sprite.play("WalkLeft")
		Vector2.RIGHT:
			sprite.flip_h = true
			sprite.play("WalkLeft")
	
func update_turning_animation():
	var dir = vector_from_direction(facing_direction)
	match dir:
		Vector2.DOWN: 
			sprite.play("TurnDown")
		Vector2.UP:
			sprite.play("TurnUp")
		Vector2.LEFT:
			sprite.flip_h = false
			sprite.play("TurnLeft")
		Vector2.RIGHT:
			sprite.flip_h = true
			sprite.play("TurnLeft")
	
	ray2d.target_position = dir * TILE_SIZE / 2
	ray2d.force_raycast_update()
	
func say_dialogue(text: String = "") -> void:
	if text.is_empty():
		text = dialogue
	var string = npc_name + ": " + text
	DialogueManager.show_dialogue(string)
	await DialogueManager.dialogue_closed
	
#region Vector/Direction enum translation
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
	
func snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(
		floor(pos.x / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2.0,
		floor(pos.y / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2.0
	)
#endregion
