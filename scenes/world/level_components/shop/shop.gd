extends Interactable

@export var inventory: Array[ItemSlot] = []
@export var welcome_text: String
@export var sprite: AnimatedSprite2D
@export var facing_dir: Vector2

func setup():
	add_to_group("can_save")
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
	shop.set_inventory(inventory, self)
	
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
		
func on_save_game(saved_data: Array[SavedData]):
	var my_data = SavedData.new()
	my_data.node_path = get_path()
	my_data.inventory = inventory
	saved_data.append(my_data)
	
func on_load_game(saved_data_array: Array[SavedData]):
	for data in saved_data_array:
		if data.node_path == get_path():
			print("got node path")
			inventory = data.inventory
