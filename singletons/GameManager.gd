extends Node

signal input_state_changed

enum InputState {OVERWORLD, BATTLE, DIALOGUE, INACTIVE}
var input_state: InputState = InputState.OVERWORLD:
	set(value):
		input_state = value
		input_state_changed.emit()
