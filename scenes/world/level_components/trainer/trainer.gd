class_name Trainer extends EncounterZone


@export_range(0, 1) var encounter_chance: float = 1.0
@export var trainer_name: String = "Trainer"
@export var ai_profile: AiProfile
@export var team: Array[MonsterData] = []
@export var levels: Array[int] = []
@export var defeated: bool = false

@export_subgroup("Text")
@export var fight_text: String
@export var defeat_text: String
@export var post_fight_text: String
@export_subgroup("Body Info")
@export var static_body: StaticBody2D
@export var facing_dir: Vector2

var tween

func setup():
	add_to_group("can_save")
	add_to_group("interactable")
	
func trigger(pos: Vector2):
	print("Trainer:", get_path(), "defeated:", defeated)
	print("defeated:",  defeated)
	if defeated:
		print("already defeated")
		return
	print("checking raycast")
	if check_ray_cast2d(pos):
		walk_to_player(pos)
		
	
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
	
func walk_to_player(pos: Vector2):
	print("walking to player")
	const TILE_SIZE = 16
	const WALK_SPEED = 5.0
	var distance = static_body.position.distance_to(pos)
	var tiles_to_travel = distance /TILE_SIZE
	var duration = tiles_to_travel / WALK_SPEED
	
	var local_target = to_local(pos)
	
	tween = get_tree().create_tween()
	tween.tween_property(static_body, "position", local_target, duration)
	await tween.finished
	print("tween finished")
	DialogueManager.show_dialogue(fight_text)
	await DialogueManager.dialogue_closed
	build_encounter()
	
func build_encounter():
	AiManager.set_ai(ai_profile, self)
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
	
