extends Node

var ai_profile

func set_ai_profile(profile: AiProfile):
	ai_profile = profile
	print("got ai_profile: ", ai_profile)

func get_enemy_action(monster: Monster):
	pass
