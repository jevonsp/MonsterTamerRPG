extends Node

signal game_speed_changed

enum Speed {SLOW = 0, MEDIUM = 1, FAST = 2}
var GameSpeed = Speed.MEDIUM

const SLOW: float = 1.0
const MEDIUM: float = .5
const FAST: float = .25

var game_speed: float:
	get:
		match GameSpeed:
			Speed.SLOW: return SLOW
			Speed.MEDIUM: return MEDIUM
			Speed.FAST: return FAST
		return MEDIUM
	set(value):
		game_speed = value
		game_speed_changed.emit(value)
