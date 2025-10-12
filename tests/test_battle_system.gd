# test_battle_system.gd
# Place in: res://tests/test_battle_system.gd
# Requires GUT testing framework (install from AssetLib)

extends GutTest

var battle_manager  # Will reference the autoload
var test_monster_data: MonsterData
var test_move: Move
var test_effect: Effect

func _mock_signal():
	pass  # Empty callback to auto-complete awaits

func before_each():
	# Reference the autoload singletons directly
	battle_manager = BattleManager
	
	# Mock EventBus signals to prevent test hangs
	if not EventBus.battle_switch.is_connected(_mock_signal):
		EventBus.battle_switch.connect(_mock_signal)
	if not EventBus.effect_ended.is_connected(_mock_signal):
		EventBus.effect_ended.connect(_mock_signal)
	
	# Clear any existing battle state
	if battle_manager.enemy_party:
		battle_manager.enemy_party.clear()
	if battle_manager.turn_actions:
		battle_manager.turn_actions.clear()
	battle_manager.player_actor = null
	battle_manager.enemy_actor = null
	battle_manager.in_battle = false
	battle_manager.processing_turn = false
	
	# Create test resources
	test_effect = Effect.new()
	test_effect.type = "DAMAGE"
	test_effect.base_power = 40
	
	test_move = Move.new()
	test_move.name = "Test Slap"
	test_move.priority = 0
	test_move.target_type = "ENEMY"
	test_move.damage_category = "PHYSICAL"
	test_move.effects = [test_effect]
	
	test_monster_data = MonsterData.new()
	test_monster_data.name = "Test Mon"
	test_monster_data.base_hitpoints = 50
	test_monster_data.base_speed = 50
	test_monster_data.base_attack = 50
	test_monster_data.base_defense = 50
	test_monster_data.base_special_attack = 50
	test_monster_data.base_special_defense = 50
	var moves_array: Array[Move] = [test_move]
	var levels_array: Array[int] = [1]
	test_monster_data.moves = moves_array
	test_monster_data.levels = levels_array

func after_each():
	# Clean up after each test
	if battle_manager and battle_manager.enemy_party:
		battle_manager.enemy_party.clear()
	if battle_manager and battle_manager.turn_actions:
		battle_manager.turn_actions.clear()
	if battle_manager:
		battle_manager.player_actor = null
		battle_manager.enemy_actor = null
		battle_manager.in_battle = false
		battle_manager.processing_turn = false

# ============================================================================
# MONSTER TESTS
# ============================================================================

func test_monster_creation():
	var monster = Monster.new()
	monster.setup_monster(test_monster_data, 5)
	
	assert_eq(monster.name, "Test Mon", "Monster name should match")
	assert_eq(monster.level, 5, "Monster level should be 5")
	assert_gt(monster.max_hitpoints, 0, "HP should be positive")
	assert_eq(monster.hitpoints, monster.max_hitpoints, "Should start at full HP")
	assert_false(monster.is_fainted, "Should not be fainted initially")
	assert_eq(monster.moves.size(), 1, "Should have 1 move")

func test_monster_hp_cannot_go_negative():
	var monster = Monster.new()
	monster.setup_monster(test_monster_data, 5)
	
	monster.take_damage(9999)
	
	assert_eq(monster.hitpoints, 0, "HP should clamp at 0")
	assert_true(monster.is_fainted, "Should be fainted")

func test_monster_hp_cannot_exceed_max():
	var monster = Monster.new()
	monster.setup_monster(test_monster_data, 5)
	
	monster.take_damage(10)
	monster.heal_damage(9999)
	
	assert_eq(monster.hitpoints, monster.max_hitpoints, "HP should clamp at max")

func test_monster_faints_at_zero_hp():
	var monster = Monster.new()
	monster.setup_monster(test_monster_data, 5)
	var initial_hp = monster.hitpoints
	
	monster.take_damage(initial_hp)
	
	assert_true(monster.is_fainted, "Should be fainted at 0 HP")
	assert_eq(monster.hitpoints, 0, "HP should be exactly 0")

func test_monster_exact_lethal_damage():
	var monster = Monster.new()
	monster.setup_monster(test_monster_data, 5)
	var exact_hp = monster.hitpoints
	
	monster.take_damage(exact_hp)
	
	assert_eq(monster.hitpoints, 0, "HP should be exactly 0")
	assert_true(monster.is_fainted, "Should be fainted")

func test_monster_moves_learned_at_level():
	var monster = Monster.new()
	monster.setup_monster(test_monster_data, 1)
	
	assert_eq(monster.moves.size(), 1, "Level 1 should have 1 move")

func test_monster_max_four_moves():
	var data = MonsterData.new()
	data.name = "Multi Move Mon"
	data.base_hitpoints = 50
	data.base_speed = 50
	data.base_attack = 50
	data.base_defense = 50
	data.base_special_attack = 50
	data.base_special_defense = 50
	
	# Create 6 moves
	for i in range(6):
		var move = Move.new()
		move.name = "Move " + str(i)
		var effect_array: Array[Effect] = [test_effect]
		move.effects = effect_array
		data.moves.append(move)
		data.levels.append(i + 1)
	
	var monster = Monster.new()
	monster.setup_monster(data, 10)
	
	assert_lte(monster.moves.size(), 4, "Should have max 4 moves")

# ============================================================================
# BATTLE MANAGER TESTS
# ============================================================================

func test_add_enemies_different_array_sizes():
	var monsters: Array[MonsterData] = [test_monster_data]
	var levels: Array[int] = [5, 10]  # Mismatched size
	
	battle_manager.add_enemies(monsters, levels)
	
	assert_eq(battle_manager.enemy_party.size(), 0, "Should reject mismatched arrays")

func test_add_enemies_success():
	var monsters: Array[MonsterData] = [test_monster_data, test_monster_data]
	var levels: Array[int] = [5, 10]
	
	battle_manager.add_enemies(monsters, levels)
	
	assert_eq(battle_manager.enemy_party.size(), 2, "Should add 2 enemies")
	assert_eq(battle_manager.enemy_party[0].level, 5, "First should be level 5")
	assert_eq(battle_manager.enemy_party[1].level, 10, "Second should be level 10")
	assert_not_null(battle_manager.enemy_actor, "Enemy actor should be set")

func test_enemy_actor_set_to_first_enemy():
	var monsters: Array[MonsterData] = [test_monster_data]
	var levels: Array[int] = [5]
	
	battle_manager.add_enemies(monsters, levels)
	
	assert_eq(battle_manager.enemy_actor, battle_manager.enemy_party[0], 
		"Enemy actor should be first party member")

func test_check_victory_all_enemies_fainted():
	var monsters: Array[MonsterData] = [test_monster_data]
	var levels: Array[int] = [5]
	battle_manager.add_enemies(monsters, levels)
	battle_manager.in_battle = true
	
	battle_manager.enemy_party[0].is_fainted = true
	var victory = await battle_manager.check_victory()
	
	assert_true(victory, "Should detect victory")
	assert_false(battle_manager.in_battle, "Battle should end")

func test_check_victory_some_enemies_alive():
	var monsters: Array[MonsterData] = [test_monster_data, test_monster_data]
	var levels: Array[int] = [5, 5]
	battle_manager.add_enemies(monsters, levels)
	battle_manager.in_battle = true
	
	battle_manager.enemy_party[1].is_fainted = true
	battle_manager.enemy_party[0].is_fainted = false
	
	var victory = await battle_manager.check_victory()
	
	assert_false(victory, "Should not detect victory with alive enemies")

func test_get_next_enemy_monster_valid():
	var monsters: Array[MonsterData] = [test_monster_data, test_monster_data]
	var levels: Array[int] = [5, 5]
	battle_manager.add_enemies(monsters, levels)
	
	battle_manager.enemy_party[0].is_fainted = true
	var next_index = battle_manager.get_next_enemy_monster()
	
	assert_eq(next_index, 1, "Should return index 1")

func test_get_next_enemy_monster_all_fainted():
	var monsters: Array[MonsterData] = [test_monster_data]
	var levels: Array[int] = [5]
	battle_manager.add_enemies(monsters, levels)
	
	battle_manager.enemy_party[0].is_fainted = true
	var next_index = battle_manager.get_next_enemy_monster()
	
	assert_eq(next_index, -1, "Should return -1 when all fainted")

func test_end_battle_clears_data():
	var monsters: Array[MonsterData] = [test_monster_data]
	var levels: Array[int] = [5]
	battle_manager.add_enemies(monsters, levels)
	battle_manager.player_actor = Monster.new()
	
	battle_manager.end_battle()
	
	assert_eq(battle_manager.enemy_party.size(), 0, "Enemy party should be empty")
	assert_null(battle_manager.player_actor, "Player actor should be null")
	assert_null(battle_manager.enemy_actor, "Enemy actor should be null")

# ============================================================================
# ACTION TESTS
# ============================================================================

func test_move_action_damage_calculation():
	var attacker = Monster.new()
	attacker.setup_monster(test_monster_data, 5)
	var defender = Monster.new()
	defender.setup_monster(test_monster_data, 5)
	
	var move_action = MoveAction.new(attacker, [0], test_move)
	var damage = move_action.calculate_damage(defender, test_effect)
	
	assert_gt(damage, 0, "Damage should be positive")
	assert_lt(damage, defender.max_hitpoints * 2, "Damage shouldn't exceed 2x max HP")

func test_move_action_minimum_damage():
	var attacker = Monster.new()
	attacker.setup_monster(test_monster_data, 5)
	var defender = Monster.new()
	defender.setup_monster(test_monster_data, 5)
	
	# Extreme defense
	defender.defense = 9999
	
	var move_action = MoveAction.new(attacker, [0], test_move)
	var damage = move_action.calculate_damage(defender, test_effect)
	
	assert_gte(damage, 0, "Damage should never be negative")

func test_switch_action_priority():
	var monster = Monster.new()
	var switch_action = SwitchAction.new(monster, [], 1)
	
	assert_eq(switch_action.priority, 6, "Switch should have priority 6")

func test_run_action_priority():
	var monster = Monster.new()
	var run_action = RunAction.new(monster, [])
	
	assert_eq(run_action.priority, 7, "Run should have priority 7")

func test_move_action_inherits_move_priority():
	var high_priority_move = Move.new()
	high_priority_move.priority = 5
	var effect_array: Array[Effect] = [test_effect]
	high_priority_move.effects = effect_array
	
	var monster = Monster.new()
	var move_action = MoveAction.new(monster, [], high_priority_move)
	
	assert_eq(move_action.priority, 5, "Move action should inherit move priority")

# ============================================================================
# EDGE CASE TESTS
# ============================================================================

func test_damage_to_already_fainted_monster():
	var monster = Monster.new()
	monster.setup_monster(test_monster_data, 5)
	monster.take_damage(999)
	
	assert_true(monster.is_fainted, "Should be fainted")
	
	monster.take_damage(50)
	
	assert_eq(monster.hitpoints, 0, "HP should stay at 0")
	assert_true(monster.is_fainted, "Should remain fainted")

func test_heal_fainted_monster():
	var monster = Monster.new()
	monster.setup_monster(test_monster_data, 5)
	monster.take_damage(999)
	
	assert_true(monster.is_fainted, "Should be fainted")
	
	monster.heal_damage(10)
	
	assert_gt(monster.hitpoints, 0, "HP should increase")
	assert_true(monster.is_fainted, "Should remain fainted - heal doesn't revive")

func test_monster_with_low_base_stats():
	var weak_data = MonsterData.new()
	weak_data.name = "Weak Mon"
	weak_data.base_hitpoints = 1
	weak_data.base_speed = 1
	weak_data.base_attack = 1
	weak_data.base_defense = 1
	weak_data.base_special_attack = 1
	weak_data.base_special_defense = 1
	var move_array: Array[Move] = [test_move]
	var level_array: Array[int] = [1]
	weak_data.moves = move_array
	weak_data.levels = level_array
	
	var monster = Monster.new()
	monster.setup_monster(weak_data, 1)
	
	assert_gt(monster.max_hitpoints, 0, "HP should be positive")
	assert_gt(monster.speed, 0, "Speed should be positive")

func test_level_1_vs_level_100_damage():
	var weak = Monster.new()
	weak.setup_monster(test_monster_data, 1)
	var strong = Monster.new()
	strong.setup_monster(test_monster_data, 100)
	
	var move_action = MoveAction.new(strong, [0], test_move)
	var damage = move_action.calculate_damage(weak, test_effect)
	
	assert_gt(damage, weak.hitpoints, "High level should one-shot low level")

func test_empty_enemy_party():
	var next = battle_manager.get_next_enemy_monster()
	
	assert_eq(next, -1, "Should return -1 for empty party")

func test_battle_with_no_moves():
	var no_move_data = MonsterData.new()
	no_move_data.name = "No Moves"
	no_move_data.base_hitpoints = 50
	no_move_data.base_speed = 50
	no_move_data.base_attack = 50
	no_move_data.base_defense = 50
	no_move_data.base_special_attack = 50
	no_move_data.base_special_defense = 50
	var empty_moves: Array[Move] = []
	var empty_levels: Array[int] = []
	no_move_data.moves = empty_moves
	no_move_data.levels = empty_levels
	
	var monster = Monster.new()
	monster.setup_monster(no_move_data, 5)
	
	assert_eq(monster.moves.size(), 0, "Should have 0 moves")

func test_extreme_damage_overflow():
	var monster = Monster.new()
	monster.setup_monster(test_monster_data, 5)
	
	monster.take_damage(2147483647)  # Max int
	
	assert_eq(monster.hitpoints, 0, "Should handle overflow gracefully")

func test_negative_damage_input():
	var monster = Monster.new()
	monster.setup_monster(test_monster_data, 5)
	var initial_hp = monster.hitpoints
	
	monster.take_damage(-50)
	
	# This actually heals! Potential bug
	assert_gte(monster.hitpoints, initial_hp, "Negative damage heals (bug?)")

func test_experience_calculation_edge_cases():
	var monster = Monster.new()
	
	var exp_0 = monster.experience_to_level(1)
	var exp_100 = monster.experience_to_level(100)
	
	assert_eq(exp_0, 0, "Level 1 should have 0 experience")
	assert_gt(exp_100, exp_0, "Level 100 should have more experience")

# ============================================================================
# INTEGRATION TESTS
# ============================================================================

func test_full_battle_until_ko():
	# Setup a quick battle
	var monsters: Array[MonsterData] = [test_monster_data]
	var levels: Array[int] = [5]
	battle_manager.add_enemies(monsters, levels)
	
	var player = Monster.new()
	player.setup_monster(test_monster_data, 5)
	battle_manager.player_actor = player
	battle_manager.in_battle = true
	
	# Attack until someone faints
	var max_turns = 100
	var turn_count = 0
	
	while not battle_manager.enemy_actor.is_fainted and turn_count < max_turns:
		battle_manager.enemy_actor.take_damage(5)
		turn_count += 1
	
	assert_true(battle_manager.enemy_actor.is_fainted, "Enemy should faint eventually")
	assert_lt(turn_count, max_turns, "Battle shouldn't infinite loop")

func test_simultaneous_ko_both_last_monsters():
	var monsters: Array[MonsterData] = [test_monster_data]
	var levels: Array[int] = [5]
	battle_manager.add_enemies(monsters, levels)
	
	var player = Monster.new()
	player.setup_monster(test_monster_data, 5)
	battle_manager.player_actor = player
	
	# Set both to 1 HP
	player.hitpoints = 1
	battle_manager.enemy_actor.hitpoints = 1
	
	# Both take fatal damage
	player.take_damage(10)
	battle_manager.enemy_actor.take_damage(10)
	
	assert_true(player.is_fainted, "Player should be fainted")
	assert_true(battle_manager.enemy_actor.is_fainted, "Enemy should be fainted")
