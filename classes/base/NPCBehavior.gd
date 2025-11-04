@abstract
class_name NPCBehavior extends Resource

@export var enabled: bool = true
@export var should_stop_chain: bool = false

func execute(_interactor, _npc: NPC) -> void:
	pass
