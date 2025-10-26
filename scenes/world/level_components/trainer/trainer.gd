class_name Trainer extends EncounterZone

@export_range(0, 1) var encounter_chance: float = 1.0
@export var team: Array[MonsterData] = []
@export var levels: Array[int] = []

@export var defeated: bool = false

@export var ai_profile: AiProfile

func setup():
	add_to_group("can_save")
	
func trigger(pos: Vector2):
	print("stepped in trainer zone")
	print("defeated:", defeated)
	if defeated:
		print("already defeated")
		return
	print("trigger for trainer hit")
	if check_ray_cast2d(pos):
		AiManager.set_ai(ai_profile, self)
		build_encounter()
	
func check_ray_cast2d(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var ray_params = PhysicsRayQueryParameters2D.create(global_position, pos)
	ray_params.collide_with_areas = true
	ray_params.collide_with_bodies = false
	ray_params.collision_mask = 3 
	ray_params.exclude = [self]
	var ray_result = space_state.intersect_ray(ray_params)
	print(ray_result.is_empty())
	return ray_result.is_empty()
	
func build_encounter():
	EventBus.toggle_player.emit()
	BattleManager.add_enemies(team, levels)
	BattleManager.is_wild = false
	BattleManager.start_battle()

func on_save_game(saved_data: Array[SavedData]):
	var my_data = SavedData.new()
	my_data.scene_path = scene_file_path
	my_data.node_path = get_path()
	my_data.defeated = defeated
	saved_data.append(my_data)
	
func on_before_load_game():
	pass
	
func on_load_game(saved_data_array: Array[SavedData]):
	for data in saved_data_array:
		if data.node_path == get_path():
			print("matching node path")
			defeated = data.defeated
	print("defeated: ", defeated)
