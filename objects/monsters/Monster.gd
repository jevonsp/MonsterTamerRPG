class_name Monster extends Resource

var species: MonsterData

var name: String = ""
var type: String = ""
var role: String = ""
var capture_rate: int = 0
var level: int = 1
var experience: int = 0

var is_fainted: bool = false
var capture_in_progress: bool = false
var getting_exp: bool = false

var max_hitpoints: int = 0
var hitpoints: int = 0
var speed: int = 0
var attack: int = 0
var defense: int = 0
var special_attack: int = 0
var special_defense: int = 0

var stat_stages: Dictionary = {
	"speed": 0,
	"attack": 0,
	"defense": 0,
	"special_attack": 0,
	"special_defense": 0,
	"accuracy": 0,
	"evasion": 0
}

var moves: Array[Move]

var status: StatusEffect = null

var held_item: Item = null

func setup_monster(md: MonsterData, lvl: int) -> void:
	species = md
	capture_rate = species.capture_rate
	level = lvl
	name = species.name
	type = species.type
	role = species.role
	experience = experience_to_level(level)
	decide_nature()
	set_stats()
	set_moves()
	print("monster created: ", name)
	print("capture rate: ", capture_rate)
	print("monster level: ", level)
	print("monster experience: ", experience)
	print("hitpoints: ", hitpoints)
	print("speed: ", speed)
	print("attack: ", attack)
	print("defense: ", defense)
	print("special_attack: ", special_attack)
	print("special_defense: ", special_defense)
	print("moves: ")
	for move in moves:
		print(" - ", move.name)
	
func decide_nature():
	pass
	
func set_stats() -> void:
	max_hitpoints = int((2 * species.base_hitpoints * level) / 100.0) + level + 10
	hitpoints = max_hitpoints
	speed = int((((2 * species.base_speed * level) / 100.0) + 5) * 1)
	attack = int((((2 * species.base_attack * level) / 100.0) + 5) * 1)
	defense = int((((2 * species.base_defense * level) / 100.0) + 5) * 1)
	special_attack = int((((2 * species.base_special_attack * level) / 100.0) + 5) * 1)
	special_defense = int((((2 * species.base_special_defense * level) / 100.0) + 5) * 1)
	
func get_stat(stat: String) -> int:
	var base_value: int = 0
	
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
	
	if stat in stat_stages:
		var stage = stat_stages[stat]
		base_value = int(base_value * _get_stage_multi(stage))
	
	if status:
		return status.modify_stat(stat, base_value)
		
	#for effect in statuses:
		#base_value = effect.modify_stat(stat, base_value)
	
	return base_value
	
func _get_stage_multi(stage: int) -> float:
	stage = clamp(stage, -6, 6)
	if stage >= 0:
		return (2.0 + stage) / 2.0
	return 2.0 / (2.0 - stage)
	
func experience_to_level(lvl: int) -> int:
	var BASE = 50
	return BASE * (lvl - 1)
	
func gain_exp(amount: int) -> void:
	var old_level = level
	
	experience += amount
	var new_level = level
	while experience >= experience_to_level(new_level + 1) and new_level < 100:
		new_level += 1
	
	var levels_gained = new_level - old_level
	
	if levels_gained > 0:
		level = new_level
		set_stats()
		
	EventBus.exp_changed.emit(self, old_level, experience, levels_gained)
	
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
	
func add_move(move: Move):
	if moves.size() == 4:
		var should_replace = await DialogueManager.show_choice(
			"%s already has 4 moves. Do you wish to remove one?" % name )
		if should_replace:
			await decide_move(move)
		else:
			DialogueManager.show_dialogue("%s did not learn %s" % [name, move.name], true)
	DialogueManager.show_dialogue("%s learned %s" % [name, move.name])
	await DialogueManager.dialogue_closed
	moves.append(move)
	
func decide_move(move: Move):
	print("pick a move to replace with: ", move.name)
	print("open summary screen here")
	
func take_damage(amount: int):
	var starting = hitpoints
	if amount <= 0:
		return
	hitpoints -= amount
	EventBus.health_changed.emit(self, starting, hitpoints)
	await EventBus.health_done_animating
	await Engine.get_main_loop().process_frame
	if hitpoints <= 0:
		is_fainted = true
		hitpoints = 0
		EventBus.monster_fainted.emit(self)
		await EventBus.fainting_done_animating
		await Engine.get_main_loop().process_frame
	
func heal(amount: int) -> void:
	var starting = hitpoints
	hitpoints += amount
	EventBus.health_changed.emit(self, starting, hitpoints)
	await EventBus.health_done_animating
	print("health finished animating")
	await Engine.get_main_loop().process_frame
	if hitpoints >= max_hitpoints:
		hitpoints = max_hitpoints
	
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
	
