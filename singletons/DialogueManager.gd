extends Node

signal dialogue_closed

var dialogue_scene = preload("res://scenes/ui/dialogue/dialogue_box.tscn")
var current_dialogue: Node = null

func show_dialogue(text: String, auto_close: bool = false) -> void:
	print("show dialogue called")
	if current_dialogue:
		UiManager.pop_ui(current_dialogue)
		
	current_dialogue = UiManager.push_ui(UiManager.dialogue_scene)
	await get_tree().process_frame
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
