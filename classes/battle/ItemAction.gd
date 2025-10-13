class_name ItemAction extends BattleAction

var item: Item

func _init(actor_ref: Monster, target_refs: Array, item_data: Item):
	item = item_data
	priority = item.priority
	super("ITEM", item_data, actor_ref, target_refs)
	
func execute() -> void:
	for effect in item.effects:
		var resolved_targets = BattleManager.resolve_targets(effect.target_type, actor)
		print("ItemEffect:", effect, "Targets:", resolved_targets)
		
		for t in resolved_targets:
			if not t or t.is_fainted:
				continue
			
			effect.apply(actor, t, item)
			print("ItemAction applying effect:", effect)
			await EventBus.effect_ended
			print("Effect ended, continuing turn")
