class_name MonsterBall extends Interactable

@export var frame: int = 0
@export var sprite: Sprite2D
@export var level: int = 3

var pyro_badger = preload("res://objects/monsters/pyro_badger/Pyro_Badger.tres")
var pistol_shrimp = preload("res://objects/monsters/pistol_shrimp/Pistol_Shrimp.tres")
var fox_mcleaf = preload("res://objects/monsters/fox_mcleaf/Fox_McLeaf.tres")

func setup():
	sprite.frame = frame

func interact(_interactor = null):
	if frame == 0:
		PartyManager.make_monster(pyro_badger, level)
		dialogue()
	if frame == 1:
		PartyManager.make_monster(pistol_shrimp, level)
		dialogue()
	if frame == 2:
		PartyManager.make_monster(fox_mcleaf, level)
		dialogue()
	obtain()
	for node in linked_nodes:
		node.obtain()
	
func dialogue():
	var monster
	if frame == 0:
		monster = pyro_badger
	if frame == 1:
		monster = pistol_shrimp
	if frame == 2:
		monster = fox_mcleaf
	DialogueManager.show_dialogue("You got a level %s %s" % [level, monster.name], false)
	await DialogueManager.dialogue_closed
	
func on_save_game(saved_data: Array[SavedData]):
	var my_data = SavedData.new()
	my_data.scene_path = scene_file_path
	my_data.node_path = get_path()
	my_data.obtained = obtained
	saved_data.append(my_data)
	
func on_load_game(saved_data_array: Array[SavedData]):
	for data in saved_data_array:
		if data.node_path == get_path():
			print("matching node path")
			obtained = data.obtained
	if obtained:
		obtain()
