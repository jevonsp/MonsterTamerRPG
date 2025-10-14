class_name ItemAction extends BattleAction

var item: Item
var target

func _init(actor_ref: Monster, target_refs: Array, item_data: Item):
	item = item_data
	if item.target_type == "ALLY":
		target = target_refs
	else:
		pass
	priority = item.priority
	super("ITEM", item_data, actor_ref)
	
func execute() -> void:
	for effect in item.effects:
		var resolved_targets
		if item.target_type == "ALLY":
			resolved_targets = target
		else:
			resolved_targets = BattleManager.resolve_targets(effect.target_type, actor)
		for t in resolved_targets:
			if not t:
				continue
			effect.apply(actor, t, item)
			print("ItemAction applying effect:", effect.name)
			print("Effect ended, continuing turn")
			print("ItemEffect: ", effect.name, " Target :", t.name)
			await EventBus.effect_ended
			
