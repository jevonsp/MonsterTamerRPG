class_name Trainer2 extends NPC

#region Variables
const TILE_SIZE: int = 16

@export var ai_profile: AiProfile

@export_subgroup("Team")
@export var team: Array[MonsterData] = []
@export var levels: Array[int] = []

@export_subgroup("Text")
@export var fight_text: String = ""
@export var defeat_text: String = ""
@export var post_fight_text: String = ""

@export_subgroup("Flags")
@export var defeated: bool = false
@export var vision_enabled: bool = true
@export var sight_tile_distance: int = 5

var sight_distance: float = sight_tile_distance * TILE_SIZE
#endregion

func _ready() -> void:
	super()
	add_to_group("trainers")
	EventBus.step_completed.connect(_on_player_step)
	
	behaviors = [
		create_movement_behavior(),
		create_dialogue_behavior(),
		create_trainer_behavior(),
		create_post_fight_behavior()
	]
	
	print(behaviors)
	
func _on_player_step(player_pos: Vector2):
	if defeated or not vision_enabled:
		return
	if is_player_in_sight(player_pos):
		var player = get_tree().get_first_node_in_group("player")
		print("got player in sight")
		
func is_player_in_sight(player_pos: Vector2) -> bool:
	var distance = global_position.distance_to(player_pos)
	print("distance:", distance)
	if distance > sight_distance:
		return false
	var to_player = (player_pos - global_position).normalized()
	print("to_player:", to_player)
	var forward = vector_from_direction(facing_direction).normalized()
	print("forward: ", forward)
	if to_player.dot(forward) != 1:
		print("to_player.dot(forward):", to_player.dot(forward))
		return false
	return check_ray_cast2d(player_pos)
	
func check_ray_cast2d(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var ray_params = PhysicsRayQueryParameters2D.create(global_position, pos)
	ray_params.collide_with_areas = true
	ray_params.collide_with_bodies = false
	ray_params.collision_mask = 3 
	ray_params.exclude = [self]
	var ray_result = space_state.intersect_ray(ray_params)
	print("ray_result.is_empty(): ", ray_result.is_empty())
	return ray_result.is_empty()
	
func create_movement_behavior(): # Movement 
	var movement = MovementBehavior.new()
	return movement
func create_dialogue_behavior(): # Dialogue
	var dialogue = DialogueBehavior.new()
	dialogue.dialogues.append(fight_text)
	return dialogue
func create_trainer_behavior(): # What actually starts the fight
	pass
func create_post_fight_behavior(): # Dialogue 
	pass
