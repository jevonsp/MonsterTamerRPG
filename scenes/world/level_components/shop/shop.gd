extends Interactable

@export var inventory: Array[ItemSlot] = []
@export var welcome_text: String
@export var sprite: AnimatedSprite2D
@export var facing_dir: Vector2

func setup():
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
	print("interacted")
	turn(interactor)
	dialogue()
	
func dialogue():
	var string = "Welcome to my shop!"
	if welcome_text:
		string = welcome_text
	DialogueManager.show_dialogue(string, true)
	await DialogueManager.dialogue_closed
	open_store()
	
func open_store():
	var shop = UiManager.push_ui(UiManager.shop_scene)
	shop.set_inventory(inventory)
	
func turn(interactor):
	var direction = (interactor.global_position - global_position).normalized()
	if abs(direction.x) > abs(direction.y):
		sprite.play("TurnLeft")
		sprite.flip_h = direction.x > 0
	else:
		sprite.flip_h = false
		if direction.y > 0:
			sprite.play("TurnDown")
		else:
			sprite.play("TurnUp")
		
