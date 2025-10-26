@abstract
class_name EncounterZone extends Area2D

var shape

func _ready() -> void:
	add_to_group("encounter")
	EventBus.step_completed.connect(_on_step_completed)
	EventBus.obstacle_removed.connect(_on_obstacle_removed)
	setup()
	shape_setup()
	
func setup():
	pass
	
func shape_setup():
	for child in get_children():
		if child is CollisionShape2D:
			shape = child
			break
		if child is CollisionPolygon2D:
			shape = child
			break
			
func _on_obstacle_removed(pos: Vector2):
	await DialogueManager.dialogue_closed
	print("got obstacle removed")
	if shape and check_position(pos):
		var player = get_tree().get_first_node_in_group("player")
		player.processing = false
		trigger(pos)
	
func _on_step_completed(pos: Vector2):
	if shape and check_position(pos):
		trigger(pos)
	
func check_position(pos: Vector2):
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = pos
	params.collide_with_areas = true
	params.collision_mask = collision_layer
	var result = space_state.intersect_point(params, 1)
	for hit in result:
		if hit.collider == self:
			return true
	return false
	
func trigger(_pos: Vector2):
	pass
