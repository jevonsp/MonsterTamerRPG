extends EncounterZone

@export_range(0, 1) var encounter_chance: float = 1.0
@export var team: Array[Monster] = []
@export var levels: Array[Monster] = []

func trigger():
	pass
