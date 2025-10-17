extends Interactable

@export var frame: int = 0
@export var sprite: Sprite2D

var pyro_badger = preload("res://resources/monsters/Pyro_Badger.tres")
var pistol_shrimp = preload("res://resources/monsters/Pistol_Shrimp.tres")
var fox_mcleaf = preload("res://resources/monsters/Fox_McLeaf.tres")

func setup():
	sprite.frame = frame

func interact():
	print("interact")
	if frame == 0:
		PartyManager.make_monster(pyro_badger, 5)
	if frame == 1:
		PartyManager.make_monster(pistol_shrimp, 5)
	if frame == 2:
		PartyManager.make_monster(fox_mcleaf, 5)
	queue_free()
