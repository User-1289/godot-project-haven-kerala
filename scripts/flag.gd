extends Area2D

## The finish flag. Touching it ends the level, plays a sound and shows a "Play Again" panel.

@onready var cloth: Polygon2D = $Cloth
@onready var win_layer: CanvasLayer = $WinLayer
@onready var win_sound: AudioStreamPlayer = $WinSound
@onready var panel: PanelContainer = %Panel
@onready var play_again_button: Button = %PlayAgainButton

var _won := false
var _time := 0.0


func _ready() -> void:
	win_layer.visible = false
	body_entered.connect(_on_body_entered)
	play_again_button.pressed.connect(_restart)


func _process(delta: float) -> void:
	# Gently wave the flag cloth.
	_time += delta
	cloth.scale.x = 1.0 + sin(_time * 6.0) * 0.12
	cloth.skew = sin(_time * 4.0) * 0.08


func _on_body_entered(body: Node2D) -> void:
	if _won or not body is CharacterBody2D:
		return
	_won = true
	win_sound.play()
	# Freeze the player in place.
	body.velocity = Vector2.ZERO
	body.set_physics_process(false)
	_show_win_panel()


func _show_win_panel() -> void:
	win_layer.visible = true
	# Pop the panel in with a little bounce.
	panel.pivot_offset = panel.size / 2.0
	panel.scale = Vector2(0.3, 0.3)
	panel.modulate.a = 0.0
	var tween := create_tween().set_parallel()
	tween.tween_property(panel, "scale", Vector2.ONE, 0.4) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 1.0, 0.25)
	play_again_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	# Keyboard shortcut: R also restarts (Enter/Space work via the focused button).
	if _won and event is InputEventKey and event.pressed and event.keycode == KEY_R:
		_restart()


func _restart() -> void:
	get_tree().reload_current_scene()
