extends Node

signal input_state_changed

enum InputState {OVERWORLD, BATTLE, DIALOGUE, MENU, INACTIVE}
var state: InputState = InputState.OVERWORLD
var input_state: InputState:
	set(value):
		state = value
		input_state_changed.emit(value)
	get:
		return state
