class_name Monster extends Resource

@export var species: MonsterData

@export var name: String = ""
@export var gender: String = ""
@export var type: String = ""
@export var role: String = ""
@export var capture_rate: int = 0
@export var level: int = 1
@export var experience: int = 0

@export var is_fainted: bool = false
@export var capture_in_progress: bool = false
@export var getting_exp: bool = false

@export var nature: Nature
@export var max_hitpoints: int = 0
@export var hitpoints: int = 0
@export var speed: int = 0
@export var attack: int = 0
@export var defense: int = 0
@export var special_attack: int = 0
@export var special_defense: int = 0

#region Nature Dicts
enum Nature {
	HARDY, LONELY, BRAVE, ADAMANT, NAUGHTY,
	BOLD, DOCILE, RELAXED, IMPISH, LAX,
	TIMID, HASTY, SERIOUS, JOLLY, NAIVE,
	MODEST, MILD, QUIET, BASHFUL, RASH,
	CALM, GENTLE, SASSY, CAREFUL, QUIRKY }
	
const NATURE_MODIFIERS = {
	Nature.HARDY:    {"atk": 1.0, "def": 1.0, "spa": 1.0, "spd": 1.0, "spe": 1.0},
	Nature.LONELY:   {"atk": 1.1, "def": 0.9, "spa": 1.0, "spd": 1.0, "spe": 1.0},
	Nature.BRAVE:    {"atk": 1.1, "def": 1.0, "spa": 1.0, "spd": 1.0, "spe": 0.9},
	Nature.ADAMANT:  {"atk": 1.1, "def": 1.0, "spa": 0.9, "spd": 1.0, "spe": 1.0},
	Nature.NAUGHTY:  {"atk": 1.1, "def": 1.0, "spa": 1.0, "spd": 0.9, "spe": 1.0},
	Nature.BOLD:     {"atk": 0.9, "def": 1.1, "spa": 1.0, "spd": 1.0, "spe": 1.0},
	Nature.DOCILE:   {"atk": 1.0, "def": 1.0, "spa": 1.0, "spd": 1.0, "spe": 1.0},
	Nature.RELAXED:  {"atk": 1.0, "def": 1.1, "spa": 1.0, "spd": 1.0, "spe": 0.9},
	Nature.IMPISH:   {"atk": 1.0, "def": 1.1, "spa": 0.9, "spd": 1.0, "spe": 1.0},
	Nature.LAX:      {"atk": 1.0, "def": 1.1, "spa": 1.0, "spd": 0.9, "spe": 1.0},
	Nature.TIMID:    {"atk": 0.9, "def": 1.0, "spa": 1.0, "spd": 1.0, "spe": 1.1},
	Nature.HASTY:    {"atk": 1.0, "def": 0.9, "spa": 1.0, "spd": 1.0, "spe": 1.1},
	Nature.SERIOUS:  {"atk": 1.0, "def": 1.0, "spa": 1.0, "spd": 1.0, "spe": 1.0},
	Nature.JOLLY:    {"atk": 1.0, "def": 1.0, "spa": 0.9, "spd": 1.0, "spe": 1.1},
	Nature.NAIVE:    {"atk": 1.0, "def": 1.0, "spa": 1.0, "spd": 0.9, "spe": 1.1},
	Nature.MODEST:   {"atk": 0.9, "def": 1.0, "spa": 1.1, "spd": 1.0, "spe": 1.0},
	Nature.MILD:     {"atk": 1.0, "def": 0.9, "spa": 1.1, "spd": 1.0, "spe": 1.0},
	Nature.QUIET:    {"atk": 1.0, "def": 1.0, "spa": 1.1, "spd": 1.0, "spe": 0.9},
	Nature.BASHFUL:  {"atk": 1.0, "def": 1.0, "spa": 1.0, "spd": 1.0, "spe": 1.0},
	Nature.RASH:     {"atk": 1.0, "def": 1.0, "spa": 1.1, "spd": 0.9, "spe": 1.0},
	Nature.CALM:     {"atk": 0.9, "def": 1.0, "spa": 1.0, "spd": 1.1, "spe": 1.0},
	Nature.GENTLE:   {"atk": 1.0, "def": 0.9, "spa": 1.0, "spd": 1.1, "spe": 1.0},
	Nature.SASSY:    {"atk": 1.0, "def": 1.0, "spa": 1.0, "spd": 1.1, "spe": 0.9},
	Nature.CAREFUL:  {"atk": 1.0, "def": 1.0, "spa": 0.9, "spd": 1.1, "spe": 1.0},
	Nature.QUIRKY:   {"atk": 1.0, "def": 1.0, "spa": 1.0, "spd": 1.0, "spe": 1.0} }
	
const NATURE_NAMES = {
	Nature.HARDY: "Hardy",
	Nature.LONELY: "Lonely", 
	Nature.BRAVE: "Brave",
	Nature.ADAMANT: "Adamant",
	Nature.NAUGHTY: "Naughty",
	Nature.BOLD: "Bold",
	Nature.DOCILE: "Docile",
	Nature.RELAXED: "Relaxed",
	Nature.IMPISH: "Impish",
	Nature.LAX: "Lax",
	Nature.TIMID: "Timid",
	Nature.HASTY: "Hasty",
	Nature.SERIOUS: "Serious",
	Nature.JOLLY: "Jolly",
	Nature.NAIVE: "Naive",
	Nature.MODEST: "Modest",
	Nature.MILD: "Mild",
	Nature.QUIET: "Quiet",
	Nature.BASHFUL: "Bashful",
	Nature.RASH: "Rash",
	Nature.CALM: "Calm",
	Nature.GENTLE: "Gentle",
	Nature.SASSY: "Sassy",
	Nature.CAREFUL: "Careful",
	Nature.QUIRKY: "Quirky"}
#endregion

#region Stat Stages Dict
var stat_stages: Dictionary = {
	"speed": 0,
	"attack": 0,
	"defense": 0,
	"special_attack": 0,
	"special_defense": 0,
	"accuracy": 0,
	"evasion": 0
}
#endregion

@export var moves: Array[Move]
@export var move_pp: Dictionary = {}

@export var status: StatusEffect = null

@export var held_item: Item = null

func setup_monster(md: MonsterData, lvl: int) -> void:
	species = md
	capture_rate = species.capture_rate
	level = lvl
	name = species.name
	type = species.type
	role = species.role
	experience = experience_to_level(level)
	decide_nature()
	decide_gender()
	set_stats()
	set_moves()
	
func decide_nature():
	nature = randi() % Nature.size() as Nature
	
func get_nature_name() -> String:
	return NATURE_NAMES.get(nature, "Unknown")
	
func decide_gender():
	print("allowed_genders: ", species.allowed_genders)
	match species.allowed_genders:
		"NONE": 
			gender = "NONE"
		"MALE": 
			gender = "MALE"
		"FEMALE": 
			gender = "FEMALE"
		"BOTH": 
			var choice = randi_range(0, 1)
			if choice == 0:
				gender = "MALE"
			elif choice == 1:
				gender = "FEMALE"
	print("gender: ", gender)
	
func set_stats() -> void:
	max_hitpoints = int((2 * species.base_hitpoints * level) / 100.0) + level + 10
	hitpoints = max_hitpoints
	var mods = NATURE_MODIFIERS[nature]
	speed = int((((2 * species.base_speed * level) / 100.0) + 5) * mods["spe"]) 
	attack = int((((2 * species.base_attack * level) / 100.0) + 5) * mods["atk"]) 
	defense = int((((2 * species.base_defense * level) / 100.0) + 5)  * mods["def"])
	special_attack = int((((2 * species.base_special_attack * level) / 100.0) + 5) * mods["spa"]) 
	special_defense = int((((2 * species.base_special_defense * level) / 100.0) + 5) * mods["spd"]) 
	
func get_stat(stat: String) -> float:
	var base_value: float = 0.0
	
	match stat:
		"hitpoints": base_value = hitpoints
		"speed": base_value = speed
		"attack": base_value = attack
		"defense": base_value = defense
		"special_attack": base_value = special_attack
		"special_defense": base_value = special_defense
		_: 
			push_error("Unknown stat param: ", stat)
			return 0
	
	if held_item and held_item.hold_effects:
		for effect in held_item.hold_effects:
			if effect.stat_to_modify == stat:
				base_value = base_value * effect.modifier
			if effect.boosted_role == role:
				base_value = base_value * effect.role_modifier
	
	if stat in stat_stages:
		var stage = stat_stages[stat]
		base_value = base_value * _get_stage_multi(stage)
	
	if status:
		return status.modify_stat(stat, base_value)
	
	return base_value
	
func _get_stage_multi(stage: int) -> float:
	stage = clamp(stage, -6, 6)
	if stage >= 0:
		return (2.0 + stage) / 2.0
	return 2.0 / (2.0 - stage)
	
func get_item_bonus():
	pass
	
func set_status(new_status: StatusEffect):
	status = new_status
	EventBus.status_changed.emit(self)
	
func experience_to_level(lvl: int) -> int:
	var BASE = 50
	return BASE * (lvl - 1)
	
func gain_exp(amount: int) -> void:
	var old_level = level
	
	experience += amount
	var levels_to_gain = 0
	var temp_level = level
	while experience >= experience_to_level(temp_level + 1) and temp_level < 100:
		levels_to_gain += 1
		temp_level +=1
	if levels_to_gain > 0:
		for i in range(levels_to_gain):
			level += 1
			set_stats()
			if self == BattleManager.player_actor:
				EventBus.exp_changed.emit(self, old_level, experience, 1)
				await EventBus.level_done_animating
			
			var new_moves = species.get_moves_at_exact_lvl(level)
			for move in new_moves:
				await add_move(move)
	else:
		if self == BattleManager.player_actor:
			EventBus.exp_changed.emit(self, old_level, experience, 0)
			await EventBus.exp_done_animating
	
func grant_exp() -> int:
	var is_getting_exp: int = 0
	for monster in PartyManager.party:
		if monster.getting_exp == true:
			is_getting_exp += 1
	var exp_yield = roundi((species.exp_value * level) / 7.0) * (1 / float(is_getting_exp))
	return exp_yield
	
func set_moves():
	var available_moves = species.get_moves_for_lvl(level)
	print(available_moves)
	if available_moves.size() > 4:
		moves = available_moves.slice(available_moves.size() - 4, available_moves.size())
	else:
		moves = available_moves.duplicate()
	for move in moves:
		move_pp[move.name] = move.max_pp
	print("move_pp:", move_pp)
	
func can_use_move(move: Move) -> bool:
	if move_pp[move.name] > 0:
		move_pp[move.name] -= 1
		print("pp left:", move_pp[move.name])
		return true
	print("pp left:", move_pp[move.name])
	return false
	
func restore_pp(move: Move):
	move_pp[move.name] = move.max_pp
	
func add_move(move: Move):
	if move in moves:
		DialogueManager.show_dialogue("%s already knows %s" % [name, move.name])
		return
		
	if moves.size() == 4:
		var should_replace = await DialogueManager.show_choice(
			"%s already has 4 moves. Do you wish to remove one?" % name )
		if should_replace:
			decide_move(move)
			return
		else:
			DialogueManager.show_dialogue("%s did not learn %s" % [name, move.name], true)
			return
	DialogueManager.show_dialogue("%s learned %s" % [name, move.name])
	await DialogueManager.dialogue_closed
	moves.append(move)
	move_pp[move.name] = move.max_pp
	
func decide_move(move: Move):
	print("pick a move to replace with: ", move.name)
	var summary = UiManager.push_ui(UiManager.summary_scene)
	print("open summary screen here")
	
	summary._set_state(summary.State.READING)
	summary.deciding = true
	summary.move_deciding = move
	summary.display_selected_monster()
	
func take_damage(amount: int):
	var starting = hitpoints
	if amount <= 0:
		return
	hitpoints -= amount
	EventBus.health_changed.emit(self, starting, hitpoints)
	EventBus.monster_hit.emit(self)
	await EventBus.health_done_animating
	await Engine.get_main_loop().process_frame
	if hitpoints <= 0:
		is_fainted = true
		hitpoints = 0
		EventBus.monster_fainted.emit(self)
		getting_exp = false
		await EventBus.fainting_done_animating
		await Engine.get_main_loop().process_frame
	
func heal(amount: int, full: bool = false) -> void:
	print("heal called")
	if full:
		amount = max_hitpoints - hitpoints
	var starting = hitpoints
	hitpoints += amount
	if hitpoints >= max_hitpoints:
		hitpoints = max_hitpoints
	if BattleManager.in_battle:
		EventBus.health_changed.emit(self, starting, hitpoints)
		await EventBus.health_done_animating
		await Engine.get_main_loop().process_frame
		return
	if not UiManager.ui_stack.is_empty():
		EventBus.health_changed.emit(self, starting, hitpoints)
		await  EventBus.party_effect_ended
	print("health finished animating")
	await Engine.get_main_loop().process_frame
	
func revive() -> void:
	is_fainted = false
	EventBus.monster_revived.emit(self)
	
func attempt_capture(capture_value: int, instant: bool):
	capture_in_progress = true
	if instant:
		EventBus.capture_shake.emit(0)
		await EventBus.shake_done_animating
		await Engine.get_main_loop().process_frame
		get_captured()
		return
	else:
		var a = capture_value
		var b = calculate_shake_threshold(a)
		var probability = (a / 1044480.0) ** 0.75
		print("Capture probability: ", snappedf(probability * 100, 0.01), "%")
		print("Shake threshold (b): ", b, " / 65536")
				
		var is_critical = get_critical_capture()
		var success = await shake_check(is_critical, b)
		if success:
			DialogueManager.show_dialogue("Success! %s was caught" % name, false)
			await DialogueManager.dialogue_closed
			await get_captured()
		else:
			DialogueManager.show_dialogue("%s failed to be caught" % name, false)
			await DialogueManager.dialogue_closed
	capture_in_progress = false
		
func calculate_shake_threshold(capture_value: int) -> int:
	var ratio = capture_value / 1044480.0
	var fourth_root = pow(ratio, 0.25)
	return int(floor(65536.0 * fourth_root))
	
func shake_check(critical: bool, chance: int) -> bool:
	if not capture_in_progress:
		return false
	var shake_number = 1 if critical else 3
	for i in range(shake_number):
		var roll = randi() % 65536
		print("Shake ", i + 1, ": rolled ", roll, " vs ", chance, " - ", "SUCCESS" if roll < chance else "FAIL")
		if roll >= chance:
			EventBus.capture_shake.emit(self, i)
			await EventBus.shake_done_animating
			return false
	EventBus.capture_shake.emit(self, shake_number)
	await EventBus.shake_done_animating
	await Engine.get_main_loop().process_frame
	return true
	
func get_critical_capture() -> bool:
	return false
	
func get_captured():
	EventBus.capture_animation.emit(self)
	await EventBus.capture_done_animating
	PartyManager.add_monster(self)
	await Engine.get_main_loop().process_frame
	BattleManager.captured(self)
	
