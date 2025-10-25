extends Node

var ai_profile: AiProfile
var trainer: Trainer

func set_ai(profile: AiProfile, trainer_ref: Trainer):
	ai_profile = profile
	print("got ai_profile: ", ai_profile)
	trainer = trainer_ref
	print("got ai_profile: ", ai_profile)
	
func clear_ai():
	ai_profile = null
	trainer = null
	

func get_enemy_action(monster: Monster):
	if not ai_profile:
		push_error("No ai profile")
		return null
	print("AiManager getting enemy action ")
	match ai_profile.battle_type:
		ai_profile.BattleType.WILD:
			print("enemy ai profile = wild")
			print("getting random move")
			var index = randi_range(0, monster.moves.size() - 1)
			var enemy_move = monster.moves[index]
			var enemy_target_index: int = -1
			if BattleManager.single_battle:
				enemy_target_index = 0
			elif not BattleManager.single_battle:
				enemy_target_index = [0, 2].pick_random()
			var enemy_action = MoveAction.new(monster, [enemy_target_index], enemy_move)
			print("enemy action: ", enemy_action)
			return enemy_action
		ai_profile.BattleType.TRAINER:
			var enemy_action = get_trainer_action(monster)
			return enemy_action
			
func get_trainer_action(monster):
	var enemy_target_index: int = -1
	var enemy_action: BattleAction
	if ai_profile.uses_items:
		if monster.hitpoints <= (monster.hitpoints / monster.max_hitpoints):
			for item in ai_profile.inventory:
				for effect in item.effects:
					if effect.name == "HEAL":
						if BattleManager.single_battle:
							enemy_target_index = 1
						elif not BattleManager.single_battle:
							enemy_target_index = [1, 3].pick_random()
						enemy_action = ItemAction.new(monster, [enemy_target_index], item)
						return enemy_action
			for move in monster.moves:
				for effect in move.effect:
					if effect.name == "HEAL":
						if BattleManager.single_battle:
							enemy_target_index = 1
						elif not BattleManager.single_battle:
							enemy_target_index = [1, 3].pick_random()
						enemy_action = ItemAction.new(monster, [enemy_target_index], move)
						return enemy_action
	
	print("more complex trainer logic here")
	print("getting random move (for now)")
	var index = randi_range(0, monster.moves.size() - 1)
	var enemy_move = monster.moves[index]
	if BattleManager.single_battle:
		enemy_target_index = 0
	elif not BattleManager.single_battle:
		enemy_target_index = [0, 2].pick_random()
	enemy_action = MoveAction.new(monster, [enemy_target_index], enemy_move)
	print("enemy action: ", enemy_action)
	return enemy_action
