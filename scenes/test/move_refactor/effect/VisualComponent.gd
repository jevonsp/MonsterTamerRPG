class_name VisualComponent extends EffectComponent

@export_enum("ACTOR", "TARGET", "THROWN", "CENTER") var animation_type = "TARGET"
@export var animation: PackedScene
@export var success_message: String = "{actor} used {move} on {target}!"

func apply(actor: Monster, target: Monster, context: Dictionary) -> bool:
	#print("==VisualComponent.execute():==")
	#print("Actor Name: ", actor.name)
	#print("Actor: ", actor)
	#print("Target Name: ", target.name)
	#print("Target: ", target)
	
	if BattleManager.in_battle and animation:
		EventBus.effect_started.emit(animation_type, actor, target, animation)
		await EventBus.effect_ended
		
	if success_message != "":
		var move_obj = context.get("move")
		var move_name = move_obj.name if move_obj else ""
		var message = success_message.format({
			"actor": actor.name,
			"target": target.name,
			"move": move_name
		})
		DialogueManager.show_dialogue(message)
		await DialogueManager.dialogue_closed
		
	return true
