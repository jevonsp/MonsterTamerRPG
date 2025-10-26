class_name Wild extends EncounterZone

@export_range(0, 1) var encounter_chance: float = 0.5
@export var encounters: Array[MonsterData] = []
@export var min_levels: Array[int] = []
@export var max_levels: Array[int] = []
@export var probabilities: Array[float] = []

@export var ai_profile: AiProfile

func trigger(_pos):
	if randf() < encounter_chance:
		print("trigger battle")
		AiManager.set_ai(ai_profile, null)
		build_encounter()
	else:
		print("did not trigger battle")
	
func build_encounter() -> void:
	var roll = randf()
	var cumulative: float = 0.0
	for i in probabilities.size():
		cumulative += probabilities[i]
		if roll <= cumulative:
			var monster = encounters[i]
			var level = randi_range(min_levels[i], max_levels[i])
			EventBus.toggle_player.emit()
			BattleManager.add_enemies([monster], [level])
			BattleManager.start_battle()
			return
	push_error("Failed to select encoutner")
