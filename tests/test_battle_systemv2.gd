# test_battle_system_minimal.gd
extends GutTest

func before_each():
	# Clear any existing state
	PartyManager.party.clear()
	InventoryManager.inventory.clear()
	BattleManager.enemy_party.clear()
	BattleManager.turn_actions.clear()
	BattleManager.in_battle = false
	BattleManager.processing_turn = false

# ============================================================================
# BASIC MONSTER TESTS
# ============================================================================

func test_monster_creation():
	var monster_data = MonsterData.new()
	monster_data.name = "TestMon"
	monster_data.base_hitpoints = 50
	monster_data.base_speed = 50
	monster_data.base_attack = 50
	monster_data.base_defense = 50
	monster_data.base_special_attack = 50
	monster_data.base_special_defense = 50
	
	var monster = Monster.new()
	monster.setup_monster(monster_data, 5)
	
	assert_eq(monster.name, "TestMon")
	assert_eq(monster.level, 5)
	assert_gt(monster.max_hitpoints, 0)
	assert_false(monster.is_fainted)

func test_monster_take_damage():
	var monster_data = MonsterData.new()
	monster_data.base_hitpoints = 50
	var monster = Monster.new()
	monster.setup_monster(monster_data, 5)
	
	var initial_hp = monster.hitpoints
	monster.take_damage(10)
	
	assert_eq(monster.hitpoints, initial_hp - 10)

func test_monster_heal():
	var monster_data = MonsterData.new()
	monster_data.base_hitpoints = 50
	var monster = Monster.new()
	monster.setup_monster(monster_data, 5)
	
	monster.take_damage(20)
	var damaged_hp = monster.hitpoints
	monster.heal(10)
	
	assert_eq(monster.hitpoints, damaged_hp + 10)

# ============================================================================
# BASIC BATTLE MANAGER TESTS
# ============================================================================

func test_battle_manager_add_enemies():
	var monster_data = MonsterData.new()
	monster_data.name = "EnemyMon"
	
	BattleManager.add_enemies([monster_data], [5])
	
	assert_eq(BattleManager.enemy_party.size(), 1)
	assert_eq(BattleManager.enemy_party[0].name, "EnemyMon")

func test_battle_manager_resolve_targets_self():
	var monster_data = MonsterData.new()
	var monster = Monster.new()
	monster.setup_monster(monster_data, 5)
	
	var targets = BattleManager.resolve_targets("SELF", monster)
	
	assert_eq(targets.size(), 1)
	assert_eq(targets[0], monster)

# ============================================================================
# BASIC ACTION TESTS
# ============================================================================

func test_move_action_creation():
	var monster_data = MonsterData.new()
	var monster = Monster.new()
	monster.setup_monster(monster_data, 5)
	
	var move = Move.new()
	move.name = "TestMove"
	
	var action = MoveAction.new(monster, [], move)
	
	assert_eq(action.type, "MOVE")
	assert_eq(action.actor, monster)
	assert_eq(action.move, move)

func test_switch_action_creation():
	var monster_data = MonsterData.new()
	var monster = Monster.new()
	monster.setup_monster(monster_data, 5)
	
	var action = SwitchAction.new(monster, [], 1)
	
	assert_eq(action.type, "SWITCH")
	assert_eq(action.switch_index, 1)

func test_run_action_creation():
	var monster_data = MonsterData.new()
	var monster = Monster.new()
	monster.setup_monster(monster_data, 5)
	
	var action = RunAction.new(monster, [])
	
	assert_eq(action.type, "RUN")

# ============================================================================
# BASIC STATUS EFFECT TESTS
# ============================================================================

func test_burn_status_creation():
	var status = BurnStatus.new()
	assert_eq(status.name, "BURN")

func test_burn_stat_modification():
	var status = BurnStatus.new()
	var result = status.modify_stat("attack", 100)
	assert_eq(result, 50)

func test_paralyze_status_creation():
	var status = ParalyzeStatus.new()
	assert_eq(status.name, "PARALYZE")

# ============================================================================
# BASIC PARTY MANAGER TESTS
# ============================================================================

func test_party_manager_add_monster():
	var monster_data = MonsterData.new()
	monster_data.name = "PartyMon"
	
	PartyManager.make_monster(monster_data, 5)
	
	assert_eq(PartyManager.party.size(), 1)
	assert_eq(PartyManager.party[0].name, "PartyMon")

func test_party_manager_get_first_alive():
	var monster_data = MonsterData.new()
	PartyManager.make_monster(monster_data, 5)
	
	var first = PartyManager.get_first_alive()
	
	assert_not_null(first)
	assert_false(first.is_fainted)

# ============================================================================
# BASIC INVENTORY TESTS
# ============================================================================

func test_inventory_add_item():
	var item = Item.new()
	item.name = "TestItem"
	
	InventoryManager.add_items(item, 3)
	
	assert_eq(InventoryManager.inventory.size(), 1)
	assert_eq(InventoryManager.inventory[0]["quantity"], 3)
	assert_eq(InventoryManager.inventory[0]["item"], item)

# ============================================================================
# TYPE EFFECTIVENESS TESTS (Simple)
# ============================================================================

func test_type_effectiveness_fire_vs_grass():
	var damage_effect = Damage.new()
	var effectiveness = damage_effect.get_type_effectiveness("FIRE", "GRASS")
	assert_eq(effectiveness, 1.5)

func test_type_effectiveness_fire_vs_water():
	var damage_effect = Damage.new()
	var effectiveness = damage_effect.get_type_effectiveness("FIRE", "WATER")
	assert_eq(effectiveness, 0.5)

# ============================================================================
# SIMPLE INTEGRATION TESTS
# ============================================================================

func test_battle_start_stop():
	var player_data = MonsterData.new()
	var enemy_data = MonsterData.new()
	
	PartyManager.make_monster(player_data, 5)
	BattleManager.add_enemies([enemy_data], [5])
	
	BattleManager.start_battle()
	assert_true(BattleManager.in_battle)
	
	# Note: Can't test end_battle fully without UI dependencies
	# But we can verify the initial state

func test_party_swap():
	var monster1 = Monster.new()
	var monster1_data = MonsterData.new()
	monster1.setup_monster(monster1_data, 5)
	
	var monster2 = Monster.new()
	var monster2_data = MonsterData.new()
	monster2.setup_monster(monster2_data, 5)
	
	PartyManager.party = [monster1, monster2]
	PartyManager.swap_party(0, 1, true)
	
	assert_eq(PartyManager.party[0], monster2)
	assert_eq(PartyManager.party[1], monster1)
