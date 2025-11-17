class_name MoveAction2 extends BattleAction

var move: Move2

func _init(actor_ref: Monster, target_refs: Array, move_data: Move2):
	move = move_data
	priority = move.priority
	super("MOVE", move_data, actor_ref, target_refs)
	
func execute() -> void:
	if BattleManager.in_battle:
		DialogueManager.show_dialogue("%s used %s!" % [actor.name, move.name], true)
		
	targets = BattleManager.resolve_targets(move.target_type, actor)
	
	for target in targets:
		if not target or target.is_fainted:
			continue
		await move.execute(actor, target)
