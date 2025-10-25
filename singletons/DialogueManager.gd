extends Node

signal dialogue_closed

var current_dialogue: Node = null
var current_choice_box: Node = null

func show_dialogue(text: String, auto_close: bool = false) -> void:
	print("show dialogue called")
	if current_dialogue:
		UiManager.pop_ui(current_dialogue)
		
	current_dialogue = UiManager.push_ui(UiManager.dialogue_scene)
	print("current_dialogue", current_dialogue)
	#await get_tree().process_frame
	if not current_dialogue:
		return
	current_dialogue.display_text(text)
	if auto_close:
		await get_tree().create_timer(Settings.game_speed).timeout
		close_dialogue()
	else:
		await EventBus.advance_dialogue
		close_dialogue()
		
func close_dialogue() -> void:
	if current_dialogue:
		UiManager.pop_ui(current_dialogue)
		current_dialogue = null
	dialogue_closed.emit()
	
func show_choice(text: String) -> bool:
	if text != "":
		show_dialogue(text, false)
	var choice_box = UiManager.push_ui(UiManager.choice_scene)
	var result = await choice_box.choice_selected
	
	print("result: ", result)
	
	UiManager.pop_ui(choice_box)
	close_dialogue()
	
	return result
