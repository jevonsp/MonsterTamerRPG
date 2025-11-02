extends Node

func _ready() -> void:
	call_deferred("initialize_floors")

func initialize_floors():
	hide_all_floors()
	show_floor("floor_0")
	
func hide_all_floors():
	print("hiding floors")
	for floor_num in [-1, 0, 1]:
		hide_floor("floor_%s" % floor_num)
			
func hide_floor(group_name: String):
	var nodes = get_tree().get_nodes_in_group(group_name)
	print("Hiding %s nodes in group %s" % [nodes.size(), group_name])
	for node in nodes:
		node.visible = false
		if node is TileMapLayer:
			node.set_collision_enabled(false)
		elif node is StaticBody2D:
			node.set_collision_layer_value(1, false)
			print("node layer: ", node.collision_layer)
			node.set_collision_mask_value(1, false)
			print("node mask: ", node.collision_mask)
		elif node is Area2D:
			node.set_collision_layer_value(1, false)
			node.set_collision_mask_value(1, false)
		
func show_floor(group_name: String):
	print("showing %s" % group_name)
	var nodes = get_tree().get_nodes_in_group(group_name)
	print("Showing %s nodes in group %s" % [nodes.size(), group_name])
	for node in nodes:
		node.visible = true
		if node is TileMapLayer:
			node.set_collision_enabled(true)
		elif node is StaticBody2D:
			node.set_collision_layer_value(1, true)
			node.set_collision_mask_value(1, true)
		elif node is Area2D:
			node.set_collision_layer_value(1, true)
			node.set_collision_mask_value(1, true)
