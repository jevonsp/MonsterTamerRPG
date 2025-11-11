extends CanvasLayer

const HP_SCALE: float = 10.0

@export var player_portrait: TextureRect
@export var enemy_portrait: TextureRect
@export var player_hp_bar: TextureProgressBar
@export var enemy_hp_bar: TextureProgressBar
@export var player_exp_bar: TextureProgressBar
@export var player_name: Label
@export var enemy_name: Label
@export var player_level: Label
@export var enemy_level: Label
@export var player_status: NinePatchRect
@export var enemy_status: NinePatchRect
@export var center_marker: Marker2D
@export var player_marker: Marker2D
@export var enemy_marker: Marker2D
@export var player_path_follow: PathFollow2D
@export var enemy_path_follow: PathFollow2D

var hp_map: Dictionary = {}
var exp_map: Dictionary = {}
var portrait_map: Dictionary = {}
var name_map: Dictionary = {}
var level_map: Dictionary = {}
var status_map: Dictionary = {}
var path_map: Dictionary = {}

func _ready() -> void:
	EventBus.player_battle_actor_sent.connect(_on_player_battle_actor_sent)
	EventBus.enemy_battle_actor_sent.connect(_on_enemy_battle_actor_sent)
	print("single visuals 3 _ready called")
	EventBus.request_battle_actors.emit()
	print("request_battle_actors sent")
	connect_signals()
	EventBus.battle_reference.emit(self)
	for status in [player_status, enemy_status]:
		status.visible = false
	
func connect_signals():
	if not EventBus.effect_started.is_connected(_on_effect_started):
		EventBus.effect_started.connect(_on_effect_started)
	if not EventBus.health_changed.is_connected(_on_health_changed):
		EventBus.health_changed.connect(_on_health_changed)
	if not EventBus.status_changed.is_connected(_on_status_changed):
		EventBus.status_changed.connect(_on_status_changed)
	if not EventBus.exp_changed.is_connected(_on_exp_changed):
		EventBus.exp_changed.connect(_on_exp_changed)
	if not EventBus.switch_animation.is_connected(_on_switch_animation):
		EventBus.switch_animation.connect(_on_switch_animation)
	if not EventBus.monster_fainted.is_connected(_on_monster_fainted):
		EventBus.monster_fainted.connect(_on_monster_fainted)
	if not EventBus.capture_shake.is_connected(_on_capture_shake):
		EventBus.capture_shake.connect(_on_capture_shake)
	if not EventBus.capture_animation.is_connected(_on_capture_animation):
		EventBus.capture_animation.connect(_on_capture_animation)
	if not EventBus.monster_hit.is_connected(_on_monster_hit):
		EventBus.monster_hit.connect(_on_monster_hit)
		
	print("connected signals")
	
func _on_player_battle_actor_sent(monster: Monster):
	print("player_battle_actor recieved: ", monster)
	map_actor(monster)
	
func _on_enemy_battle_actor_sent(monster: Monster):
	print("enemy_battle_actor recieved: ", monster)
	map_actor(monster)
	
func map_actor(monster: Monster) -> void:
	var is_player = (monster == BattleManager.player_actor)
	
	var hp_bar = player_hp_bar if is_player else enemy_hp_bar
	hp_bar.max_value = monster.max_hitpoints * HP_SCALE
	hp_bar.value = monster.hitpoints * HP_SCALE
	hp_map[monster] = hp_bar
	
	if is_player:
		var level_start = monster.experience_to_level(monster.level)
		var level_end = monster.experience_to_level(monster.level + 1)
		player_exp_bar.max_value = level_end - level_start
		player_exp_bar.value = monster.experience - level_start
		player_exp_bar.min_value = 0
		exp_map[monster] = player_exp_bar
	
	var portrait = player_portrait if is_player else enemy_portrait
	portrait.texture = monster.species.sprite
	portrait_map[monster] = portrait
	
	var name_label = player_name if is_player else enemy_name
	name_label.text = monster.species.name
	name_map[monster] = name_label
	
	var level_label = player_level if is_player else enemy_level
	level_label.text = "Lvl. " + str(monster.level)
	level_map[monster] = level_label
	
	var status_label = player_status if is_player else enemy_status
	if monster.status != null:
		status_label.status = monster.status.name
		status_map[monster] = status_label
		
	var path_follow = player_path_follow if is_player else enemy_path_follow
	path_map[monster] = path_follow
	
func update_maps(old_monster: Monster, new_monster: Monster) -> void:
	var hp_bar = hp_map.get(old_monster)
	if hp_bar:
		hp_bar.max_value = new_monster.max_hitpoints * HP_SCALE
		hp_bar.value = new_monster.hitpoints * HP_SCALE
		hp_map.erase(old_monster)
		hp_map[new_monster] = hp_bar
	var exp_bar = exp_map.get(old_monster)
	if exp_bar:
		var level_start = new_monster.experience_to_level(new_monster.level)
		var level_end = new_monster.experience_to_level(new_monster.level + 1)
		exp_bar.max_value = level_end - level_start
		exp_bar.value = new_monster.experience - level_start
		exp_map.erase(old_monster)
		exp_map[new_monster] = exp_bar
	var portrait = portrait_map.get(old_monster)
	if portrait:
		portrait.texture = new_monster.species.sprite
		portrait_map.erase(old_monster)
		portrait_map[new_monster] = portrait
	var name_label = name_map.get(old_monster)
	if name_label:
		name_label.text = new_monster.name
		name_map.erase(old_monster)
		name_map[new_monster] = name_label
	var level_label = level_map.get(old_monster)
	if level_label:
		level_label.text = "Lvl. " + str(new_monster.level)
		level_map.erase(old_monster)
		level_map[new_monster] = level_label
	var status_label = status_map.get(old_monster)
	if status_label:
		if new_monster.status != null:
			status_label.status = new_monster.status.name
		status_map.erase(old_monster)
		status_map[new_monster] = status_label
	var path_follow = path_map.get(old_monster)
	if path_follow:
		path_map.erase(old_monster)
		path_map[new_monster] = path_follow
	
func clear_maps():
	portrait_map.clear()
	hp_map.clear()
	exp_map.clear()
	
func _on_effect_started(animation_type: String, actor: Monster, target: Monster, effect_anim):
	print("animation_type: ", animation_type)
	animate_effect(animation_type, actor, target, effect_anim)
	await get_tree().create_timer(Settings.game_speed * 2).timeout
	EventBus.effect_ended.emit()
	
func animate_effect(animation_type: String, actor: Monster, target: Monster, effect_anim: PackedScene) -> void:
	print("playing: ", effect_anim)
	var effect_center: Vector2
	if not effect_anim:
		return
	var effect: Node2D = effect_anim.instantiate()
	add_child(effect)
	
	var anim = effect.get_node_or_null("AnimatedSprite2D")
	anim.play()
	
	effect.visibility_layer = 10
	
	if actor == BattleManager.enemy_actor:
		anim.flip_h = true
	
	match animation_type:
		"ACTOR":
			if actor == BattleManager.player_actor:
				effect_center = player_marker.global_position
			else:
				effect_center = enemy_marker.global_position
		"TARGET":
			if target == BattleManager.player_actor:
				effect_center = player_marker.global_position
			else:
				effect_center = enemy_marker.global_position
		"CENTER":
			effect_center = center_marker.position
		"THROWN":
			var start_marker: Marker2D = player_marker if actor == BattleManager.player_actor else enemy_marker
			var end_marker: Marker2D = player_marker if target == BattleManager.player_actor else enemy_marker
			effect.position = start_marker.global_position
			var tween = get_tree().create_tween()
			tween.tween_property(effect, "position", end_marker.global_position, Settings.game_speed * 2)
			await get_tree().create_timer(Settings.game_speed * 2).timeout
			effect.queue_free()
			return
	effect.position = effect_center
	await get_tree().create_timer(Settings.game_speed).timeout
	effect.queue_free()
	
func _on_health_changed(monster: Monster, _old: int, new: int) -> void:
	print("do health animation here")
	var tween = get_tree().create_tween()
	tween.tween_property(hp_map[monster], "value", new * HP_SCALE, Settings.game_speed)
	await tween.finished
	EventBus.health_done_animating.emit()
	
func _on_monster_hit(monster: Monster) -> void:
	print("would play %s getting hit" % monster.name)
	var path_follow = path_map.get(monster)
	var tween = get_tree().create_tween()
	tween.tween_property(path_follow, "progress_ratio", 1.0, Settings.game_speed / 4)
	await tween.finished
	path_follow.progress_ratio = 0.0
	
func _on_status_changed(monster: Monster) -> void:
	var status_label = status_map.get(monster)
	if status_label:
		status_label.status = monster.status.name
	
func _on_monster_revived(_monster: Monster) -> void:
	print("do revive animation here")
	await get_tree().create_timer(Settings.game_speed).timeout
	EventBus.monster_revive_done_animating.emit()
	
func _on_switch_animation(old: Monster, new: Monster) -> void:
	var direction
	print("old: ", old)
	print("BattleManager.player_actor: ", BattleManager.player_actor)
	print("new: ", new)
	if old == BattleManager.player_actor or new == BattleManager.player_actor:
		direction = Vector2(-200,0)
	elif old == BattleManager.enemy_actor or new == BattleManager.enemy_actor:
		direction = Vector2(200,0)
	var texture = portrait_map[old]
	var start_pos = texture.position
	print("start_pos: ", start_pos)
	print("direction: ", direction)
	var tween_pos = get_tree().create_tween()
	tween_pos.tween_property(texture, "position", start_pos + direction, Settings.game_speed)
	await tween_pos.finished
	update_maps(old, new)
	var tween_back = get_tree().create_tween()
	tween_back.tween_property(texture, "position", start_pos, Settings.game_speed)
	await tween_back.finished
	print("old: ", old, " new: ", new)
	await get_tree().create_timer(Settings.game_speed).timeout
	EventBus.switch_done_animating.emit()
	
func _on_exp_changed(monster: Monster, old_level: int, new_experience: int, times: int) -> void:
	print("do experience animation here")
	if times == 1:
		# Level up animation
		var level_start = monster.experience_to_level(old_level)
		var level_end = monster.experience_to_level(old_level + 1)
		
		var full_tween = get_tree().create_tween()
		full_tween.tween_property(exp_map[monster], "value", level_end - level_start, Settings.game_speed)
		await full_tween.finished
		
		exp_map[monster].value = 0
		await get_tree().process_frame
		
		DialogueManager.show_dialogue("%s leveled up to %s" % [monster.name, old_level + 1], true)
		level_map[monster].text = "Lvl. " + str(old_level + 1)
		
		EventBus.level_done_animating.emit()
	else:
		# Just exp gain, no level up
		var level_start = monster.experience_to_level(monster.level)
		var tween = get_tree().create_tween()
		tween.tween_property(exp_map[monster], "value", new_experience - level_start, Settings.game_speed)
		await tween.finished
		
		EventBus.exp_done_animating.emit()
	
func _on_monster_fainted(monster: Monster):
	var texture = portrait_map[monster]
	var start_pos = texture.position
	var start_size = texture.size
	print("do fainting animation here")
	
	var tween_size = get_tree().create_tween()
	tween_size.tween_property(texture, "size", Vector2(0,0), Settings.game_speed)
	var tween_pos = get_tree().create_tween()
	tween_pos.tween_property(texture, "position", start_pos + Vector2(0, 200), Settings.game_speed)
	await tween_pos.finished
	texture.texture = null
	texture.position = start_pos
	texture.size = start_size
	EventBus.fainting_done_animating.emit()
	
func _on_capture_shake(_monster: Monster, shake_number: int):
	print("do capture shake here")
	var shake_time = Settings.game_speed / 2.0
	for i in range(shake_number):
		await get_tree().create_timer(shake_time).timeout
	EventBus.shake_done_animating.emit()
	
func _on_capture_animation(_monster: Monster):
	print("do capture animation here")
	await get_tree().create_timer(Settings.game_speed).timeout
	EventBus.capture_done_animating.emit()

func _on_button_pressed() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(player_path_follow, "progress_ratio", 1.0, Settings.game_speed / 4)
	await tween.finished
	player_path_follow.progress_ratio = 0.0
