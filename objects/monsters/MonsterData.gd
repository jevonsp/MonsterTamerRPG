class_name MonsterData extends Resource

@export var name: String = ""
@export var sprite: Texture2D
@export_enum("FIRE", "WATER", "GRASS", "LIGHT", "DARK", "NONE") var type = "FIRE"
@export_enum("MELEE", "RANGED", "TANK") var role = "MELEE"
@export_range(0, 255) var capture_rate = 200
@export var exp_value: int = 50
#region Stats
@export_subgroup("Base Stats")
@export var base_hitpoints: int = 50
@export var base_speed: int = 50
@export var base_attack: int = 50
@export var base_defense: int = 50
@export var base_special_attack: int = 50
@export var base_special_defense: int = 50
#endregion
#region Moves
@export_subgroup("Moveset")
@export var moves: Array[Move] = []
@export var levels: Array[int] = []
func get_moves_for_lvl(lvl: int) -> Array[Move]:
	var available_moves: Array[Move] = []
	for i in range(moves.size()):
		if i < levels.size() and levels[i] <= lvl:
			available_moves.append(moves[i])
	return available_moves
func get_moves_at_exact_lvl(lvl: int) -> Array[Move]:
	var new_moves: Array[Move] = []
	for i in range(moves.size()):
		if i < levels.size() and levels[i] == lvl:
			new_moves.append(moves[i])
	return new_moves
#endregion
