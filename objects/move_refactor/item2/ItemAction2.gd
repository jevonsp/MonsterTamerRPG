class_name ItemAction2 extends BattleAction

var item: Item2
var target

func _init(actor_ref: Monster, target_refs: Array, item_data: Item2):
	item = item_data
	if item.target_type == "ALLY":
		target = target_refs
	else:
		target = BattleManager.resolve_targets(item.target_type, actor_ref)
	priority = item.priority
	super("ITEM", item_data, actor_ref, target)
	
func execute() -> void:
	print("item action execute")
	var resolved_targets
	if item.target_type == "ALLY":
		resolved_targets = target
	else:
		resolved_targets = BattleManager.resolve_targets(item.target_type, actor)
	
	# Execute item on each valid target
	for target_monster in resolved_targets:
		if not target_monster or target_monster.is_fainted:
			continue
		
		await item.execute(actor, target_monster)
