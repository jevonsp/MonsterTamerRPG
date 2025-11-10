class_name TutorialStopper extends Stopper

@export var tutorial_prompt: String = ""
@export var completed_message: String = ""
@export var action_waiting_for: String = ""
@export var is_completed: bool = false

func trigger(_pos: Vector2):
	pass
	
	# show tutorial_prompt
	# pause player movement, not input. wait for EventBus.action_inputted(action_waiting_for)
	# if completed_message: show completed_message
	
func on_save_game(saved_data: Array[SavedData]):
	var my_data = SavedData.new()
	my_data.scene_path = scene_file_path
	my_data.node_path = get_path()
	#my_data.is_completed = is_completed
	saved_data.append(my_data)
	
func on_load_game(saved_data_array: Array[SavedData]):
	for data in saved_data_array:
		if data.node_path == get_path():
			print("matching node path")
			#is_completed = data.is_completed
