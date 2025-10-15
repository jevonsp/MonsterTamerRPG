extends CanvasLayer

@export var player_portrait: TextureRect
@export var enemy_portrait: TextureRect

func setup_battle(player: Monster, enemy: Monster):
	setup_portraits(player, enemy)
	setup_hp_bars(player, enemy)
	setup_exp_bars(player, enemy)
	
func setup_portraits(player, enemy):
	player_portrait.texture = player.species.sprite
	enemy_portrait.texture = enemy.species.sprite
	
func setup_hp_bars(player, enemy):
	pass
func setup_exp_bars(player, enemy):
	pass
