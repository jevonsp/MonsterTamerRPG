class_name Trainer extends EncounterZone

@export_range(0, 1) var encounter_chance: float = 1.0
@export var team: Array[MonsterData] = []
@export var levels: Array[int] = []

var defeated: bool = false

func trigger(pos: Vector2):
	if defeated:
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
	ray_params.collision_mask = 3 # 2 * (layer - 1)
	ray_params.exclude = [self]
	var ray_result = space_state.intersect_ray(ray_params)
	print(ray_result.is_empty())
	return ray_result.is_empty()
	
func build_encounter():
	EventBus.toggle_player.emit()
	BattleManager.add_enemies(team, levels)
	BattleManager.is_wild = false
	BattleManager.start_battle()
