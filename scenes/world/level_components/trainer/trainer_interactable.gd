extends Interactable

@export var trainer: Trainer
@export var body: AnimatableBody2D
@export var sprite: AnimatedSprite2D

func setup():
	var facing_dir = trainer.facing_dir 
	if abs(facing_dir.x) > abs(facing_dir.y):
		sprite.play("TurnLeft")
		sprite.flip_h = facing_dir.x > 0
	else:
		sprite.flip_h = false
		if facing_dir.y > 0:
			sprite.play("TurnDown")
		else:
			sprite.play("TurnUp")

func interact(interactor = null):
	print("trainer interacted")
	turn(interactor)
	dialogue()
	
func dialogue():
	if not trainer.defeated:
		DialogueManager.show_dialogue(trainer.fight_text)
		await DialogueManager.dialogue_closed
		trainer.build_encounter()
	elif trainer.defeated:
		DialogueManager.show_dialogue(trainer.post_fight_text)
		await DialogueManager.dialogue_closed
		
func turn(interactor, pos = null):
	var direction
	if pos == null:
		direction = (interactor.global_position - global_position).normalized()
	else:
		direction = (pos - global_position).normalized
	
	if abs(direction.x) > abs(direction.y):
		sprite.play("TurnLeft")
		sprite.flip_h = direction.x > 0
	else:
		sprite.flip_h = false
		if direction.y > 0:
			sprite.play("TurnDown")
		else:
			sprite.play("TurnUp")
