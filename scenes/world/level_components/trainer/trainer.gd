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
@export var anim_body: AnimatableBody2D
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
		var player = get_tree().get_first_node_in_group("player")
		player.processing = false
		player.clear_inputs()
		print("player.processing: ",player.processing)
		await walk_to_player(pos)
		player.processing = true
		print("player.processing: ",player.processing)
		
	
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
	const TILE_SIZE = 16
	const WALK_SPEED = 5.0
	
	var player = get_tree().get_first_node_in_group("player")
	print("player pos (from function): ", pos)
	print("player actual global_position: ", player.global_position)
	print("anim_body.global_position: ", anim_body.global_position)
	print("facing_dir: ", facing_dir)
	
	# Determine which axis the trainer is looking (using facing_dir)
	var target_pos: Vector2
	
	if abs(facing_dir.x) > abs(facing_dir.y):
		# Facing horizontally - match player's Y, stop one tile away on X
		target_pos = Vector2(pos.x - (sign(facing_dir.x) * TILE_SIZE), pos.y)
		print("moving horizontally")
	else:
		# Facing vertically - match player's X, stop one tile away on Y
		target_pos = Vector2(pos.x, pos.y - (sign(facing_dir.y) * TILE_SIZE))
		print("moving vertically")
	
	print("target_pos (global): ", target_pos)
	
	var distance = anim_body.global_position.distance_to(target_pos)
	var tiles_to_travel = distance / TILE_SIZE
	var duration = tiles_to_travel / WALK_SPEED
	
	anim_body.sync_to_physics = false
	
	tween = get_tree().create_tween()
	tween.tween_property(anim_body, "global_position", target_pos, duration)
	await tween.finished
	
	anim_body.sync_to_physics = true
	
	print("final anim_body position: ", anim_body.global_position)
	print("final player position: ", player.global_position)
	
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
	
