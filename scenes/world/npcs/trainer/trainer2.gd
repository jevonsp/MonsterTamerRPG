class_name Trainer extends NPC

#region Variables
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
	
func _on_player_step(player_pos: Vector2):
	if defeated or not vision_enabled:
		return
	if is_player_in_sight(player_pos):
		var player = get_tree().get_first_node_in_group("player")
		player.clear_inputs()
		player.processing = false
		print("got player in sight")
		await walk_towards(player)
		say_dialogue(fight_text)
		await DialogueManager.dialogue_closed
		build_encounter()
		
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
	
func build_encounter():
	AiManager.set_ai(ai_profile, self)
	BattleManager.add_enemies(team, levels)
	BattleManager.is_wild = false
	BattleManager.start_battle()
