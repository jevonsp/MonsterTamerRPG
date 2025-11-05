class_name MovementBehavior extends NPCBehavior

# In MovementBehavior.gd
func execute(interactor: CharacterBody2D, npc: NPC) -> void:
	var collider = npc.ray2d.get_collider()
	if collider:
		if collider == interactor:
			print("MovementBehavior: too close, no need to walk")
			return
	print("MovementBehavior: would walk %s to %s" % [npc, interactor])
