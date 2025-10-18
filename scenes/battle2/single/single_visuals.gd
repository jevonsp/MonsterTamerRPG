extends CanvasLayer

@export var player_portrait: TextureRect
@export var enemy_portrait: TextureRect
@export var player_hp_bar: TextureProgressBar
@export var enemy_hp_bar: TextureProgressBar
@export var player_exp_bar: TextureProgressBar
@export var player_name: Label
@export var enemy_name: Label
@export var player_level: Label
@export var enemy_level: Label
@export var center_marker: Marker2D

const HP_SCALE: float = 10.0

var portrait_map: Dictionary = {}
var hp_map: Dictionary = {}
var exp_map: Dictionary = {}
var name_map: Dictionary = {}
var level_map: Dictionary = {}

func _ready() -> void:
	EventBus.battle_reference.emit(self)

func setup_battle(player: Monster, enemy: Monster):
	map_portraits(player, enemy)
	map_hp_bars(player, enemy)
	map_exp_bars(player)
	map_names(player, enemy)
	map_levels(player, enemy)
	for map in [portrait_map, hp_map, exp_map]:
		print("map:\n")
		print(map)
		
func map_portraits(player: Monster, enemy: Monster):
	player_portrait.texture = player.species.sprite
	enemy_portrait.texture = enemy.species.sprite
	portrait_map[player] = player_portrait
	portrait_map[enemy] = enemy_portrait
	
func map_hp_bars(player: Monster, enemy: Monster):
	player_hp_bar.max_value = player.max_hitpoints * HP_SCALE
	player_hp_bar.value = player.hitpoints * HP_SCALE
	enemy_hp_bar.max_value = enemy.max_hitpoints * HP_SCALE
	enemy_hp_bar.value = enemy.hitpoints * HP_SCALE
	hp_map[player] = player_hp_bar
	hp_map[enemy] = enemy_hp_bar
	
func map_exp_bars(player: Monster):
	var level_start = player.experience_to_level(player.level)
	var level_end = player.experience_to_level(player.level + 1)
	player_exp_bar.max_value = level_end - level_start
	player_exp_bar.value = player.experience - level_start
	player_exp_bar.min_value = 0
	exp_map[player] = player_exp_bar
	
func map_names(player: Monster, enemy: Monster):
	player_name.text = player.name
	enemy_name.text = enemy.name
	name_map[player] = player_name
	name_map[enemy] = enemy_name
	
func map_levels(player: Monster, enemy: Monster):
	player_level.text = "Lvl. " + str(player.level)
	enemy_level.text = "Lvl. " + str(enemy.level)
	level_map[player] = player_level
	level_map[enemy] = enemy_level
	
func update_maps(old_monster: Monster, new_monster: Monster) -> void:
	var portrait = portrait_map.get(old_monster)
	if portrait:
		portrait.texture = new_monster.species.sprite
		portrait_map.erase(old_monster)
		portrait_map[new_monster] = portrait
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
		
func clear_maps():
	portrait_map.clear()
	hp_map.clear()
	exp_map.clear()
	
func _on_effect_started(animation_type: String, actor: Monster, target: Monster, effect_anim):
	print("animation_type: ", animation_type)
	animate_effect(animation_type, actor, target, effect_anim)
	await get_tree().create_timer(Settings.game_speed).timeout
	EventBus.effect_ended.emit()
	
func animate_effect(animation_type: String, actor: Monster, target: Monster, effect_anim: PackedScene) -> void:
	var effect_center: Vector2
	var effect_target: Vector2
	if not effect_anim:
		return
	var effect: Node2D = effect_anim.instantiate()
	add_child(effect)
	
	match animation_type:
		"ACTOR":
			effect_center = portrait_map.get(actor).position
		"TARGET":
			effect_center = portrait_map.get(target).position
		"CENTER":
			effect_center = center_marker.position
		"THROWN":
			effect_center = portrait_map.get(actor).position
			effect_target = portrait_map.get(target).position
			effect.position = effect_center
			var tween = get_tree().create_tween()
			tween.tween_property(effect, "position", effect_target, Settings.game_time)
			return
	effect.position = effect_center
	get_tree().create_timer(Settings.game_speed).timeout.connect(effect.queue_free)
	
func _on_health_changed(monster: Monster, _old: int, new: int) -> void:
	print("do health animation here")
	var tween = get_tree().create_tween()
	tween.tween_property(hp_map[monster], "value", new * HP_SCALE, Settings.game_speed)
	await tween.finished
	EventBus.health_done_animating.emit()
	
func _on_switch_animation(old: Monster, new: Monster) -> void:
	var direction
	print("old: ", old)
	print("BattleManager.player_actor: ", BattleManager.player_actor)
	print("new: ", new)
	if old or new == BattleManager.player_actor:
		direction = Vector2(-200,0)
	elif old or new == BattleManager.enemy_actor:
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
	var old_lvl = old_level
	for i in times:
		var _level_start = monster.experience_to_level(old_lvl)
		var level_end = monster.experience_to_level(old_lvl + 1)
		var full_tween = get_tree().create_tween()
		full_tween.tween_property(exp_map[monster], "value", level_end - _level_start, Settings.game_speed)
		await full_tween.finished
		exp_map[monster].value = 0
		await get_tree().process_frame
		DialogueManager.show_dialogue("%s leveled up to %s" % [monster.name, old_lvl + 1], true)
		old_lvl += 1
	var level_start = monster.experience_to_level(old_lvl)
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
	pass # Test button for animations
