@abstract
class_name EncounterZone extends Area2D

var default_profile := preload("res://scenes/world/level_components/wild_zone/WildProfile1.tres")

@export var ai_profile: AiProfile = default_profile

var shape

func _ready() -> void:
	add_to_group("encounter")
	EventBus.step_completed.connect(_on_step_completed)
	setup()
	
func setup():
	for child in get_children():
		if child is CollisionShape2D:
			shape = child
			break
		if child is CollisionPolygon2D:
			shape = child
			break
	
func _on_step_completed(pos: Vector2):
	if shape and check_position(pos):
		trigger()
	
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
	
func trigger():
	pass
