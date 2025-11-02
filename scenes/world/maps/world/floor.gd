extends Node2D

@export var floor_level: int = 0

func _ready():
	# Add all descendants to the floor group
	add_all_children_to_group(self)

func add_all_children_to_group(node: Node):
	node.add_to_group("floor_%s" % floor_level)
	for child in node.get_children():
		child.add_to_group("floor_%s" % floor_level)
		print("child %s added to floor_%s" % [child, floor_level])
		# Add the child's children too
		for grandchild in child.get_children():
			grandchild.add_to_group("floor_%s" % floor_level)
			print("child %s added to floor_%s" % [grandchild, floor_level])
