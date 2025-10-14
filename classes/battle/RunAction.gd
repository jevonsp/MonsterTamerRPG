class_name RunAction extends BattleAction

var target

func _init(actor_ref: Monster, target_refs: Array) -> void:
	target = target_refs
	priority = 7
	super("RUN", null, actor_ref)
	
func execute() -> void:
	print("run attempt here")
	if calculate_escape_chance():
		# effect_type: String, actor: Monster, _target: Monster, _effect_image: Texture2D
		EventBus.effect_started.emit("RUN", actor, null, null)
		print("run succeeded")
		BattleManager.escaped = true
	else:
		print("run failed")
	
func calculate_escape_chance():
	var actor_speed = actor.speed
	var enemy_speed
	if not BattleManager.single_battle:
		enemy_speed = (BattleManager.enemy_actor.speed + BattleManager.enemy_actor2.speed) / 2.0
	else:
		enemy_speed = BattleManager.enemy_actor.speed
	BattleManager.escape_attempts += 1
	
	var escape_odds = ((actor_speed * 32) / (enemy_speed / 4.0)) + 30 * BattleManager.escape_attempts
	
	return randi_range(0, 255) < escape_odds
