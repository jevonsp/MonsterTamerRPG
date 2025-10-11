class_name SwitchAction extends BattleAction

var new_monster: Monster

func _init(actor_ref: Monster, target_refs: Array[Monster], switch_monster: Monster) -> void:
	priority = 6
	new_monster = switch_monster
	super(actor_ref, target_refs, "SWITCH", switch_monster)
	
func execute() -> void:
	pass
