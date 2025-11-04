class_name SavedData extends Resource

@export var position: Vector2
@export var scene_path: String
@export var node_path: NodePath

#region Ground Items
@export var obtained: bool
#endregion

#region Trainers
@export var defeated: bool
#endregion

#region Shops
@export var inventory: Array[ItemSlot]
#endregion

#region Story
@export var active: bool
#endregion
