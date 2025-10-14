class_name MoveAction extends BattleAction

var move: Move

func _init(actor_ref: Monster, target_refs: Array, move_data: Move):
	move = move_data
	priority = move.priority
	super("MOVE", move_data, actor_ref, target_refs)
	
func execute() -> void:
	for effect in move.effects:
		var resolved_targets = BattleManager.resolve_targets(effect.target_type, actor)
		print("Effect:", effect.name, "Targets:", targets)
		for t in resolved_targets:
			if not t or t.is_fainted:
				continue
			
			effect.apply(actor, t, move)
			await EventBus.effect_ended
