class_name SavedData extends Resource

@export var position: Vector2
@export var scene_path: String
@export var node_path: NodePath

#region Ground Items
@export var obtained: bool
#endregion

#region NPCs/Trainers
@export var is_hidden: bool
@export var defeated: bool
@export var dialogues: Array[String]
#endregion

#region Shops
@export var inventory: Array[ItemSlot]
#endregion

#region Story
@export var active: bool
#endregion
