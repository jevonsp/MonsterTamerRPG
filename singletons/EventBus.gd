extends Node

@warning_ignore_start("unused_signal")

signal battle_started(monster: Monster)

signal effect_started(effect_type: String, actor: Monster, target: Monster, image: Texture2D)
signal effect_ended

@warning_ignore_restore("unused_signal")
