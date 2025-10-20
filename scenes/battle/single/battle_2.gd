extends CanvasLayer

@export var visuals: CanvasLayer

func _ready() -> void:
	connect_signals()
			
func setup_battle():
	visuals.setup_battle(BattleManager.player_actor, BattleManager.enemy_actor)
	UiManager.push_ui(UiManager.battle_options_scene)
	
func connect_signals():
	if not EventBus.effect_started.is_connected(visuals._on_effect_started):
		EventBus.effect_started.connect(visuals._on_effect_started)
	if not EventBus.health_changed.is_connected(visuals._on_health_changed):
		EventBus.health_changed.connect(visuals._on_health_changed)
	if not EventBus.exp_changed.is_connected(visuals._on_exp_changed):
		EventBus.exp_changed.connect(visuals._on_exp_changed)
	if not EventBus.switch_animation.is_connected(visuals._on_switch_animation):
		EventBus.switch_animation.connect(visuals._on_switch_animation)
	if not EventBus.monster_fainted.is_connected(visuals._on_monster_fainted):
		EventBus.monster_fainted.connect(visuals._on_monster_fainted)
	if not EventBus.capture_shake.is_connected(visuals._on_capture_shake):
		EventBus.capture_shake.connect(visuals._on_capture_shake)
	if not EventBus.capture_animation.is_connected(visuals._on_capture_animation):
		EventBus.capture_animation.connect(visuals._on_capture_animation)
