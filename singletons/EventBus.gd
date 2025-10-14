extends Node

@warning_ignore_start("unused_signal")

signal battle_started(monster: Monster)

signal effect_started(effect_type: String, actor: Monster, target: Monster, image: Texture2D)
signal effect_ended

signal health_changed(monster: Monster, old: int, new: int)
signal health_done_animating
signal exp_changed(monster: Monster, old: int, new: int, times: int)
signal exp_done_animating

signal monster_fainted(monster: Monster)
signal fainting_done_animating

signal capture_shake(monster: Monster, shake_number: int)
signal shake_done_animating
signal capture_animation(monster: Monster)
signal capture_done_animating

signal battle_switch
signal free_switch

@warning_ignore_restore("unused_signal")
