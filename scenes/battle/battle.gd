extends CanvasLayer

var player_actor = BattleManager.player_actor
var player_actor2 = BattleManager.player_actor2
var enemy_actor = BattleManager.enemy_actor
var enemy_actor2 = BattleManager.enemy_actor2

var battle
var single = preload("res://scenes/battle/single/single_battle_ui.tscn")
var double = preload("res://scenes/battle/double/double_battle_ui.tscn")

func _ready() -> void:
	if BattleManager.single_battle:
		battle = single
	elif not BattleManager.single_battle:
		battle = double
	
	var scene = battle.instantiate()
	scene.setup_battle(BattleManager.player_actor, BattleManager.enemy_actor)
	add_child(scene)
	connect_signals(scene)
	
func connect_signals(scene: Node) -> void:
	if not EventBus.effect_started.is_connected(scene._on_effect_started):
		EventBus.effect_started.connect(scene._on_effect_started)
	if not EventBus.health_changed.is_connected(scene._on_health_changed):
		EventBus.health_changed.connect(scene._on_health_changed)
	if not EventBus.exp_changed.is_connected(scene._on_exp_changed):
		EventBus.exp_changed.connect(scene._on_exp_changed)
	if not EventBus.switch_animation.is_connected(scene._on_switch_animation):
		EventBus.switch_animation.connect(scene._on_switch_animation)
	if not EventBus.monster_fainted.is_connected(scene._on_monster_fainted):
		EventBus.monster_fainted.connect(scene._on_monster_fainted)
	if not EventBus.capture_shake.is_connected(scene._on_capture_shake):
		EventBus.capture_shake.connect(scene._on_capture_shake)
	if not EventBus.capture_animation.is_connected(scene._on_capture_animation):
		EventBus.capture_animation.connect(scene._on_capture_animation)
		
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
