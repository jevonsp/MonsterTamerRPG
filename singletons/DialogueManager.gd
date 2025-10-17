extends Node

signal dialogue_closed

var dialogue_scene = preload("res://scenes/dialogue/dialogue_box.tscn")
var current_dialogue: Node = null

func show_dialogue(text: String, auto_close: bool = false) -> void:
	print("show dialogue called")
	if current_dialogue:
		current_dialogue.queue_free()
		
	GameManager.input_state = GameManager.InputState.DIALOGUE
		
	current_dialogue = dialogue_scene.instantiate()
	add_child(current_dialogue)
	await get_tree().process_frame
	current_dialogue.display_text(text)
	if auto_close:
		await get_tree().create_timer(Settings.game_speed).timeout
		close_dialogue()
	else:
		await EventBus.advance_dialogue
		close_dialogue()
		
	if BattleManager.in_battle:
		GameManager.input_state = GameManager.InputState.BATTLE
	elif not BattleManager.in_battle:
		GameManager.input_state = GameManager.InputState.OVERWORLD
		
func close_dialogue() -> void:
	if current_dialogue:
		current_dialogue.queue_free()
		current_dialogue = null
	dialogue_closed.emit()
