extends Interactable

@export var string: String = ""
enum Direction {UP, DOWN, LEFT, RIGHT}
@export var facing_direction: Direction = Direction.DOWN
@export var down_sprite: Sprite2D
@export var left_sprite: Sprite2D
@export var right_sprite: Sprite2D

func _ready():
	super()
	for sprite in [down_sprite, left_sprite, right_sprite]:
		sprite.visible = false
	match facing_direction:
		Direction.DOWN: down_sprite.visible = true
		Direction.LEFT: left_sprite.visible = true
		Direction.RIGHT: right_sprite.visible = true
		
func interact(_interactor = null):
	print("got interaction")
	DialogueManager.show_dialogue(string)
	await DialogueManager.dialogue_closed
		
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
