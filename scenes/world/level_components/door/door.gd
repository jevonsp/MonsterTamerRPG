class_name Door extends Area2D

@export var active: bool = true
@export var floor_num: int = 0
@export_subgroup("Nodes")
@export var door_point: DoorPoint
@export var shape: CollisionShape2D
@export var blocker: StaticBody2D
@export_subgroup("Transitions")
@export var iris_effect: ColorRect

func _ready() -> void:
	set_door_state()
	EventBus.step_completed.connect(_on_step_completed)
	
func set_door_state():
	if active:
		if blocker:
			blocker.collision_layer = 0
			blocker.collision_mask = 0
	monitoring = active
	
func _on_step_completed(pos: Vector2):
	if not active:
		return
		
	if not shape:
		return
		
	if check_position(pos):
		trigger()

	
func check_position(pos: Vector2):
	var space_state = get_world_2d().direct_space_state
	
	var params = PhysicsPointQueryParameters2D.new()
	params.position = pos
	params.collide_with_areas = true
	params.collision_mask = collision_layer
	
	var result = space_state.intersect_point(params, 1)
	
	for i in result.size():
		var hit = result[i]
		if hit.collider == self:
			return true
	return false
	
func trigger():
	if door_point != null:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			iris_effect.play()
			player.clear_inputs()
			player.processing = false
			await get_tree().create_timer(0.5).timeout
			player.global_position = door_point.global_position
			player.processing = true
	else:
		print("ERROR: door_point is null")
