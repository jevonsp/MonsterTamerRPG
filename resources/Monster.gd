class_name Monster extends Resource

var species: MonsterData

var name: String = ""
var capture_rate: int = 0
var level: int = 1
var experience: int = 0

var is_fainted: bool = false

var max_hitpoints: int = 0
var hitpoints: int = 0
var speed: int = 0
var attack: int = 0
var defense: int = 0
var special_attack: int = 0
var special_defense: int = 0

var moves: Array[Move]

func setup_monster(md: MonsterData, lvl: int) -> void:
	species = md
	capture_rate = species.capture_rate
	level = lvl
	name = species.name
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
	
func experience_to_level(lvl: int) -> int:
	var BASE = 50
	return BASE * (lvl - 1)
	
func set_moves():
	var available_moves = species.get_moves_for_lvl(level)
	print(available_moves)
	if available_moves.size() > 4:
		moves = available_moves.slice(available_moves.size() - 4, available_moves.size())
	else:
		moves = available_moves.duplicate()
		
func take_damage(amount: int):
	if amount <= 0:
		return
	hitpoints -= amount
	if hitpoints <= 0:
		is_fainted = true
		hitpoints = 0
	
func heal_damage(amount: int):
	hitpoints += amount
	if hitpoints >= max_hitpoints:
		hitpoints = max_hitpoints
	
func attempt_capture(value: int):
	print("capture attempt started")
