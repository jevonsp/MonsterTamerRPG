extends Node

var party: Array[Monster] = []
var storage: Array[Monster] = []

func _ready():
	for i in range(0, 300):
		storage.append(null)

func make_monster(monster_data: MonsterData, lvl: int) -> Monster:
	var monster = Monster.new()
	monster.setup_monster(monster_data, lvl)
	if not party.size() < 6:
		print("no more room in party, adding to storage")
		for i in range(0, 300):
			if storage[i] == null:
				storage[i] = monster
				return
	party.append(monster)
	print("party: ", party)
	return monster
	
func add_monster(monster: Monster) -> void:
	if not party.size() < 6:
		print("no more room in party, adding to storage")
		for i in range(0, 300):
			if storage[i] == null:
				storage[i] = monster
				return
	party.append(monster)
	print("party: ", party)
	
func get_first_alive() -> Monster:
	for monster in party:
		if not monster.is_fainted:
			return monster
	return null
	
func show_party():
	UiManager.push_ui(UiManager.party_scene2)
	
func swap_party(from_index: int, to_index: int, free_switch: bool = true) -> void:
	if free_switch:
		print("got free switch")
		var temp = party[from_index]
		party[from_index] = party[to_index]
		party[to_index] = temp
		EventBus.free_switch_chosen.emit()
	else:
		print("not free")
		var switch = SwitchAction.new(BattleManager.player_actor, [BattleManager.enemy_actor], from_index)
		BattleManager.on_action_selected(switch)
		
func withdraw_monster(slot_enum: int) -> void:
	print("got %s" % slot_enum)
	if storage[slot_enum] != null:
		party.append(storage[slot_enum])
		storage[slot_enum] = null
	DialogueManager.show_dialogue("Withdrew %s" % party.back().name, true)
	await DialogueManager.dialogue_closed
		
func deposit_monster(slot_enum: int) -> void:
	print("got slot_enum: ", slot_enum)
	for i in range(300):
		if storage[i] == null:
			storage[i] = party[slot_enum]
			DialogueManager.show_dialogue("Deposited %s" % storage[i].name, true)
			print("storage[i]: ", storage[i], "slot: ", i)
			await DialogueManager.dialogue_closed
			party.remove_at(slot_enum)
			print("removed party slot: ", slot_enum)
			break
	print("party now: ", party)
		
func swap_storage(from_index: int, to_index: int) -> void:
	var temp = storage[from_index]
	storage[from_index] = storage[to_index]
	storage[to_index] = temp
		
func refresh_party():
	for monster in party:
		for move in monster.moves:
			monster.restore_pp(move)
