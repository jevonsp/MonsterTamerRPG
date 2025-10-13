extends CanvasLayer

var player_actor = BattleManager.player_actor

func _ready() -> void:
	EventBus.effect_started.connect(_on_effect_started)

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
	pass # Replace with function body.
	
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
	
func _on_effect_started(effect_type: String, actor: Monster, _target: Monster, _effect_image: Texture2D):
	print("effect_type: ", effect_type)
	match effect_type:
		"DAMAGE":
			if actor == BattleManager.player_actor:
				pass
			if actor == BattleManager.enemy_actor:
				pass
	await get_tree().create_timer(0.3).timeout
	EventBus.effect_ended.emit()
