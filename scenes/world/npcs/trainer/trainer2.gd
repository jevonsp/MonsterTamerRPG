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
	add_to_group("can_save")
	add_to_group("trainers")
	EventBus.step_completed.connect(_on_player_step)
	
func _on_player_step(player_pos: Vector2):
	if defeated or not vision_enabled:
		return
	if is_player_in_sight(player_pos):
		var player = get_tree().get_first_node_in_group("player")
		player.clear_inputs()
		player.processing = false
		await walk_to(player)
		say_dialogue(fight_text)
		await DialogueManager.dialogue_closed
		build_encounter()
		
func is_player_in_sight(player_pos: Vector2) -> bool:
	var distance = global_position.distance_to(player_pos)
	if distance > sight_distance:
		return false
	var to_player = (player_pos - global_position).normalized()
	var forward = vector_from_direction(facing_direction).normalized()
	if to_player.dot(forward) != 1:
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
	return ray_result.is_empty()
	
func build_encounter():
	AiManager.set_ai(ai_profile, self)
	BattleManager.add_enemies(team, levels)
	BattleManager.is_wild = false
	BattleManager.start_battle()
	
func on_save_game(saved_data: Array[SavedData]):
	var my_data = SavedData.new()
	my_data.node_path = get_path()
	my_data.defeated = defeated
	saved_data.append(my_data)
	
func on_load_game(saved_data_array: Array[SavedData]):
	for data in saved_data_array:
		if data.node_path == get_path():
			defeated = data.defeated
			dialogues[0] = post_fight_text
