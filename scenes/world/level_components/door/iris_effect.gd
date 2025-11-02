# IrisEffect.gd
extends ColorRect

@export var animation_speed: float = 4.0
@export var max_radius: float = 2.0
@export var min_radius: float = 0.0

var current_radius: float = 0.0
var is_animating: bool = false

func _ready():
	current_radius = max_radius
	material.set_shader_parameter("radius", current_radius)

func play():
	if is_animating:
		return
	visible = true
	is_animating = true
	await close_iris()
	await open_iris()
	is_animating = false
	visible = false

func close_iris():
	# Animate to closed
	while current_radius > min_radius:
		current_radius = move_toward(current_radius, min_radius, animation_speed * get_process_delta_time())
		material.set_shader_parameter("radius", current_radius)
		await get_tree().process_frame

func open_iris():
	# Animate to open
	while current_radius < max_radius:
		current_radius = move_toward(current_radius, max_radius, animation_speed * get_process_delta_time())
		material.set_shader_parameter("radius", current_radius)
		await get_tree().process_frame
