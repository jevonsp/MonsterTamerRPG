class_name Door extends Area2D

@export var active: bool = true
@export var floor_num: int = 0
@export_subgroup("Nodes")
@export var door_point: DoorPoint
@export var shape: CollisionShape2D
@export var blocker: StaticBody2D

func _ready() -> void:
	set_door_state()
	EventBus.step_completed.connect(_on_step_completed)
	print("Door ready - shape: ", shape, ", door_point: ", door_point)
	
func set_door_state():
	print("setting door state")
	print("active: ", active)
	if active:
		print("blocker: ", blocker)
		if blocker:
			blocker.collision_layer = 0
			print("blocker.collision_layer: ", blocker.collision_layer)
			blocker.collision_mask = 0
			print("blocker.collision_mask: ", blocker.collision_mask)
	monitoring = active
	print("monitoring: ", monitoring)
	
func _on_step_completed(pos: Vector2):
	print("=== DOOR: Step completed signal received ===")
	print("Position received: ", pos)
	print("Door active: ", active)
	if not active:
		print("Door not active, returning")
		return
		
	if shape:
		print("Shape exists, checking position...")
		if check_position(pos):
			print("Position check PASSED - triggering door")
			trigger()
		else:
			print("Position check FAILED - position not in door area")
	else:
		print("No shape assigned to door")
	
func check_position(pos: Vector2):
	print("--- Checking position ---")
	print("Input position: ", pos)
	print("Door global position: ", global_position)
	print("Door collision layer: ", collision_layer)
	
	var space_state = get_world_2d().direct_space_state
	print("Space state: ", space_state)
	
	var params = PhysicsPointQueryParameters2D.new()
	params.position = pos
	params.collide_with_areas = true
	params.collision_mask = collision_layer
	print("Query params - position: ", params.position, ", mask: ", params.collision_mask)
	
	var result = space_state.intersect_point(params, 1)
	print("Intersection results count: ", result.size())
	
	for i in result.size():
		var hit = result[i]
		print("Hit ", i, ": ", hit)
		print("  Collider: ", hit.collider)
		print("  This door: ", self)
		if hit.collider == self:
			print("*** MATCH FOUND - hit collider is this door ***")
			return true
	
	print("No match found in results")
	return false
	
func trigger():
	print(">>> DOOR TRIGGER <<<")
	print("door_point: ", door_point)
	if door_point != null:
		print("door_point.global_position: ", door_point.global_position)
		var player = get_tree().get_first_node_in_group("player")
		if player:
			print("Player found: ", player)
			print("Moving player from %s to %s" % [player.global_position, door_point.global_position])
			player.global_position = door_point.global_position
			print("Player position after move: ", player.global_position)
		else:
			print("ERROR: No player found in group 'player'")
	else:
		print("ERROR: door_point is null")
