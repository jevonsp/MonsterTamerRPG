extends CanvasLayer

var free: bool = false

func _ready() -> void:
	EventBus.free_switch.connect(on_free_switch)

func _on_button_1_pressed() -> void:
	switch_party_members(0)
func _on_button_2_pressed() -> void:
	switch_party_members(1)
func _on_button_3_pressed() -> void:
	switch_party_members(2)
func _on_button_4_pressed() -> void:
	switch_party_members(3)
func _on_button_5_pressed() -> void:
	switch_party_members(4)
func _on_button_6_pressed() -> void:
	switch_party_members(5)
	
func switch_party_members(switch_index: int):
	print("switch_index: ", switch_index)
	if switch_index == 0:
		print("cannot switch a monster already fighting in!")
		return
	if switch_index > PartyManager.party.size() - 1:
		print("no party member in that slot!")
		return
	if PartyManager.party[switch_index].is_fainted:
		print("cannot switch in a fainted monster!")
		return
	if free:
		var free_switch = SwitchAction.new(BattleManager.player_actor, [BattleManager.enemy_actor], switch_index)
		free_switch.execute()
		free = false
		close()
		return
	var switch = SwitchAction.new(BattleManager.player_actor, [BattleManager.enemy_actor], switch_index)
	BattleManager.on_action_selected(switch)
	close()
	
func on_free_switch():
	free = true
	print("free: ", free)
	
func close():
	queue_free()
