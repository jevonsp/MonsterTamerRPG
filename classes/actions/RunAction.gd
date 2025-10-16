class_name RunAction extends BattleAction

var target

func _init(actor_ref: Monster, target_refs: Array) -> void:
	target = target_refs
	priority = 7
	super("RUN", null, actor_ref)
	
func execute() -> void:
	if calculate_escape_chance():
		EventBus.effect_started.emit("RUN", actor, null, null)
		await EventBus.effect_ended
		BattleManager.escaped = true
		print(actor.name, " escaped!")
	else:
		print(actor.name, " couldn't escape!")
	
func calculate_escape_chance() -> bool:
	var actor_speed = actor.speed
	var enemy_speed
	if not BattleManager.single_battle:
		enemy_speed = (BattleManager.enemy_actor.speed + BattleManager.enemy_actor2.speed) / 2.0
	else:
		enemy_speed = BattleManager.enemy_actor.speed
	BattleManager.escape_attempts += 1
	
	var escape_odds = ((actor_speed * 32) / (enemy_speed / 4.0)) + 30 * BattleManager.escape_attempts
	
	return randi_range(0, 255) < escape_odds
