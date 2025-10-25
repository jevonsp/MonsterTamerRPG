extends Interactable

@export var frame: int = 0
@export var sprite: Sprite2D
@export var level: int = 3

var pyro_badger = preload("res://objects/monsters/pyro_badger/Pyro_Badger.tres")
var pistol_shrimp = preload("res://objects/monsters/pistol_shrimp/Pistol_Shrimp.tres")
var fox_mcleaf = preload("res://objects/monsters/fox_mcleaf/Fox_McLeaf.tres")

func setup():
	sprite.frame = frame

func interact():
	print("interact")
	if can_interact:
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
	

	
