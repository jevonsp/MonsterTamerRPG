extends Node

@warning_ignore_start("unused_signal")

signal battle_reference(node: Node)
signal inventory_reference(node: Node)

signal battle_manager_ready

signal step_completed(position: Vector2)
signal obstacle_removed(position: Vector2)

signal event_triggered(event: String)
signal npc_command(command: String, target: NPC, data: Dictionary)

signal request_battle_actors
signal player_battle_actor_sent(monster: Monster)
signal enemy_battle_actor_sent(monster: Monster)

signal effect_started(effect_type: String, actor: Monster, target: Monster, image: Texture2D)
signal effect_ended
signal party_effect_ended

signal health_changed(monster: Monster, old: int, new: int)
signal health_done_animating
signal monster_hit(monster: Monster)

signal status_changed(monster: Monster)

signal exp_granted(amount: int)
signal exp_changed(monster: Monster, old_level: int, new_experience: int, times: int)
signal level_done_animating
signal exp_done_animating

signal monster_fainted(monster: Monster)
signal fainting_done_animating
signal monster_revived(monster: Monster)
signal monster_revive_done_animating

signal capture_shake(monster: Monster, shake_number: int)
signal shake_done_animating
signal capture_animation(monster: Monster)
signal capture_done_animating

signal free_switch
signal free_switch_chosen
signal switch_animation(out_monster: Monster, in_monster: Monster)
signal switch_done_animating

signal advance_dialogue

signal using_item(item: Item2)
signal giving_item(item: Item2)
signal item_chosen(item: Item2)

signal move_removed

signal toggle_labels

signal behavior_completed

@warning_ignore_restore("unused_signal")
