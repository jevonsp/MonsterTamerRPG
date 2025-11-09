extends Sprite2D

#@onready var tile_map: TileMapLayer = get_node("/root/MapTestV1_0/Layers/Objects")
#
#func _physics_process(_delta: float) -> void:
	#check_tile()
	#
#func check_tile():
	#var tile_pos = tile_map.local_to_map(global_position)
	#var atlas_coords = tile_map.get_cell_atlas_coords(tile_pos)
	#
	#var grass_tiles = [Vector2i(6, 4), Vector2i(6, 5), Vector2i(7, 4), Vector2i(7, 5)]
	#if atlas_coords in grass_tiles:
		#material.set_shader_parameter("mask_bottom", 0.75)
	#else:
		#material.set_shader_parameter("mask_bottom", 0.0)
