class_name NPC extends Area2D

enum Direction {UP, DOWN, LEFT, RIGHT}
@export var npc_name: String = ""
@export var facing_direction: Direction = Direction.DOWN

@export var behaviors: Array[NPCBehavior] = []

@export_subgroup("Nodes")
@export var sprite: AnimatedSprite2D
@export var ray2d: RayCast2D

func _ready() -> void:
	setup_sprite()
	
func setup_sprite():
	if not sprite:
		return
		
	var dir = vector_from_direction(facing_direction)
	match dir:
		Vector2.DOWN: 
			sprite.play("TurnDown")
		Vector2.UP:
			sprite.play("TurnUp")
		Vector2.LEFT:
			sprite.play("TurnLeft")
		Vector2.RIGHT:
			sprite.flip_h = true
			sprite.play("TurnLeft")
		_:
			print("dir not matched")
	facing_direction = direction_from_vector(dir)
	
func interact(interactor = null) -> void:
	turn_towards(interactor)
	await get_tree().create_timer(0.1).timeout
	
	for behavior in behaviors:
		if behavior.enabled:
			@warning_ignore("redundant_await")
			await behavior.execute(interactor, self)
			if behavior.should_stop_chain:
				break
				
func turn_towards(interactor: CharacterBody2D) -> void:
	var dir = (interactor.global_position - global_position).normalized()
	if dir == vector_from_direction(facing_direction):
		return
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
	facing_direction = direction_from_vector(dir)
	const TILE_SIZE: int = 16
	ray2d.target_position = dir * TILE_SIZE / 2
	ray2d.force_raycast_update()
	
func walk_towards(_interactor: CharacterBody2D) -> void:
	pass
	
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
#endregion
