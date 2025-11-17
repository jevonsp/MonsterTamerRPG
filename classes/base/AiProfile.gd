class_name AiProfile extends Resource

enum BattleType {WILD, TRAINER}
@export var battle_type: BattleType
@export var payout: int = 50
@export var uses_items: bool = false
@export var inventory: Array[Item2]
@export var healing_threshold: float = .33
