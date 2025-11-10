class_name Interactable extends Area2D

@export var event_component: EventComponent
@export var obtained: bool = false

@export_subgroup("Linked Nodes")
@export var linked_nodes: Array[Interactable]

@export var is_hidden: bool:
	set(value):
		if value == is_hidden:
			return
		print("setting is_hidden value to: ", value)
		is_hidden = value
		shape.disabled = value
		visible = not value

var shape: Node2D

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("can_save")
	for child in get_children():
		if child is CollisionShape2D:
			shape = child
			break
		if child is CollisionPolygon2D:
			shape = child
			break
	setup()
	
func on_save_game(_saved_data: Array[SavedData]):
	pass
	
func on_before_load_game():
	pass
	
func on_load_game(_saved_data_array: Array[SavedData]):
	pass
	
func setup():
	pass
	
func interact(_interactor = null):
	pass

func dialogue():
	pass
	
func obtain():
	print("obtain called")
	obtained = true
	is_hidden = true
