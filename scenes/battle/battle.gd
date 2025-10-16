extends CanvasLayer

var player_actor = BattleManager.player_actor
var player_actor2 = BattleManager.player_actor2
var enemy_actor = BattleManager.enemy_actor
var enemy_actor2 = BattleManager.enemy_actor2

var battle_scene
var single = preload("res://scenes/battle/single/single_battle_ui.tscn")
var double = preload("res://scenes/battle/double/double_battle_ui.tscn")

func _ready() -> void:
	if not EventBus.effect_started.is_connected(_on_effect_started):
		EventBus.effect_started.connect(_on_effect_started)
	if not EventBus.health_changed.is_connected(_on_health_changed):
		EventBus.health_changed.connect(_on_health_changed)
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
	if BattleManager.single_battle:
		var scene = single.instantiate()
		scene.setup_battle(BattleManager.player_actor, BattleManager.enemy_actor)
		add_child(scene)
		battle_scene = scene
	elif not BattleManager.single_battle:
		var scene = double.instantiate()
		scene.setup_battle(BattleManager.player_actor, BattleManager.enemy_actor)
		add_child(scene)
		battle_scene = scene
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if %Moves.visible == true:
			%Moves.visible = false

func setup_battle():
	print("player_actor:", BattleManager.player_actor.name)
	print("enemy_actor:", BattleManager.enemy_actor.name)
	%Moves.visible = false
	%Targets.visible = false
	
func remove_actor():
	pass
	
func add_actor():
	pass
	
func _on_button_1_pressed() -> void:
	if not player_actor.moves[0].chooses_targets:
		var move = player_actor.moves[0]
		_on_move_selected(move)
	
func _on_button_2_pressed() -> void:
	if not player_actor.moves[0].chooses_targets:
		var move = player_actor.moves[1]
		_on_move_selected(move)
	
func _on_button_3_pressed() -> void:
	pass # Replace with function body.
	
func _on_button_4_pressed() -> void:
	pass # Replace with function body.
	
func _on_move_selected(move: Move):
	%Moves.visible = false
	var action = MoveAction.new(BattleManager.player_actor, [1], move)
	BattleManager.on_action_selected(action)
	
func _on_fight_pressed() -> void:
	%Moves.visible = true
	
func _on_party_pressed() -> void:
	PartyManager.show_party()
	
func _on_item_pressed() -> void:
	InventoryManager.show_inventory()
	
func _on_run_pressed() -> void:
	var action = RunAction.new(BattleManager.player_actor, [BattleManager.enemy_actor])
	BattleManager.on_action_selected(action)
	
func _on_effect_started(effect_type: String, actor: Monster, target: Monster, _effect):
	print("effect_type: ", effect_type)
	match effect_type:
		"ACTOR": print("effect centered on: ", actor)
		"TARGET": print("effect centered on: ", target)
		"THROWN": print("effect goes from: ", actor, " to target: ", target)
		"CENTER": print("effect centered on screen")
		"RUN": print("animate run")
	await get_tree().create_timer(Settings.game_speed).timeout
	EventBus.effect_ended.emit()
	
func _on_health_changed(_monster: Monster, _old: int, _new: int) -> void:
	print("do health animation here")
	await get_tree().create_timer(Settings.game_speed).timeout
	EventBus.health_done_animating.emit()
	
func _on_switch_animation(old: Monster, new: Monster) -> void:
	print("old: ", old, " new: ", new)
	await get_tree().create_timer(Settings.game_speed).timeout
	EventBus.switch_done_animating.emit()
	
func _on_exp_changed(monster: Monster, old_level: int, _new_experience: int, times: int) -> void:
	print("do experience animation here")
	var old_lvl = old_level
	for i in times:
		old_lvl += 1
		await get_tree().create_timer(Settings.game_speed).timeout
		DialogueManager.show_dialogue("%s leveled up to %s" % [monster.name, old_lvl], true)
	if times == 0:
		await get_tree().create_timer(Settings.game_speed).timeout
	EventBus.exp_done_animating.emit()
	
func _on_monster_fainted(_monster: Monster):
	print("do fainting animation here")
	await get_tree().create_timer(Settings.game_speed).timeout
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
