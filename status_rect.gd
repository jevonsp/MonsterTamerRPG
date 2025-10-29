extends NinePatchRect

@export_enum("BURN", "PARALYZE", "FREEZE", "POISON") var status = "BURN"
@export_subgroup("Textures")
@export var burn_texture: Texture2D
@export var paralyze_texture: Texture2D
@export var freeze_texture: Texture2D
@export var poison_texture: Texture2D
@export_subgroup("Nodes")
@export var label: Label

func _process(_delta: float) -> void:
	var new_text := ""
	match status:
		"BURN":
			texture = burn_texture
			new_text = "BURN"
		"PARALYZE":
			texture = paralyze_texture
			new_text = "PARALYZE"
		"FREEZE":
			texture = freeze_texture
			new_text = "FREEZE"
		"POISON":
			texture = poison_texture
			new_text = "POISON"
	label.text = new_text
	size.x = label.size.x + 2
	position = -size * 0.5
