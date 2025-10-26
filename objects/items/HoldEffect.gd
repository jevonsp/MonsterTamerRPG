class_name HoldEffect extends Resource

@export_subgroup("Stat Modifiers")
@export_enum("attack", "defense", "special_attack", "special_defense", "speed") var stat_to_modify: String
@export_range(0.1, 2.0, 0.1) var modifier: float = 1.0
@export_enum("FIRE", "WATER", "GRASS", "LIGHT", "DARK", "NONE") var boosted_type: String
@export_range(0.1, 2.0, 0.1) var type_modifier: float = 1.0

@export_enum("MELEE", "RANGED", "TANK") var boosted_role: String  
@export_range(0.1, 2.0, 0.1) var role_modifier: float = 1.0
