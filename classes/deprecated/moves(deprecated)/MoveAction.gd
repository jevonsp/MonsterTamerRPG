class_name MoveAction extends BattleAction

var move: Move

func _init(actor_ref: Monster, target_refs: Array, move_data: Move):
	move = move_data
	priority = move.priority
	super("MOVE", move_data, actor_ref, target_refs)
	
func execute() -> void:
	if BattleManager.in_battle:
		DialogueManager.show_dialogue("%s used %s!" % [actor.name, move.name], true)
		
	var actor_accuracy_multi = actor._get_stage_multi(actor.stat_stages["accuracy"])
	var target = BattleManager.resolve_targets(move.target_type, actor)
	var target_evasion_multi = target[0]._get_stage_multi(target[0].stat_stages["evasion"])
	var accuracy = move.accuracy * actor_accuracy_multi * target_evasion_multi
	
	if randf() > accuracy:
		DialogueManager.show_dialogue("%s's attack missed!" % actor.name)
		await DialogueManager.dialogue_closed
		return
	
	for effect in move.effects:
		var resolved_targets = BattleManager.resolve_targets(effect.target_type, actor)
		
		print("Effect:", effect.name, "Targets:", resolved_targets)
		for t in resolved_targets:
			if not t or t.is_fainted:
				continue
			
			@warning_ignore("redundant_await")
			await effect.apply(actor, t, move)
