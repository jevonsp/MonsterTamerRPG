extends Node2D

var pistol_shrimp = preload("res://resources/monsters/Pistol_Shrimp.tres")
var fox_mcleaf = preload("res://resources/monsters/Fox_McLeaf.tres")
var pyro_badger = preload("res://resources/monsters/Pyro_Badger.tres")
var potion = preload("res://resources/items/Potion.tres")
var ball = preload("res://resources/items/Ball.tres")

func _ready() -> void:
	pass
	
func _on_button_1_pressed() -> void:
	PartyManager.add_monster(pistol_shrimp, 5)
	
func _on_button_2_pressed() -> void:
	BattleManager.add_enemies([fox_mcleaf], [5])
	
func _on_button_3_pressed() -> void:
	BattleManager.start_battle()
	
func _on_button_4_pressed() -> void:
	BattleManager.end_battle()
	print("Battle hard reset!")
	
func _on_button_5_pressed() -> void:
	InventoryManager.add_items(potion, 1)
	print("Added Potion to Inventory")
	
func _on_button_6_pressed() -> void:
	InventoryManager.add_items(ball, 1)
	print("Added Ball to Inventory")
