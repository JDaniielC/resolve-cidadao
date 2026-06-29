extends CanvasLayer
## CreditsMenu handles displaying the development and creative teams with smooth animations.

@export var scale_duration: float = 0.3
@export var fade_out_duration: float = 0.2
@export var blur_alpha: float = 0.75

const FADE_OUT_DURATION: float = 0.35

var _panel: Panel
var _color_rect: ColorRect
var _back_button: Button
var _animating: bool = false

func _ready() -> void:
	layer = 102 # Render above the settings menu if both are open
	
	_panel = $Control/Panel
	_color_rect = $Control/ColorRect
	_back_button = $Control/Panel/VBoxContainer/BackButtonRow/BackButton

	if not _panel or not _color_rect or not _back_button:
		push_error("CreditsMenu: Essential nodes not found!")
		return

	_setup_animations()
	_back_button.pressed.connect(_on_back_pressed)
	get_tree().root.gui_embed_subwindows = true

func _setup_animations() -> void:
	_panel.scale = Vector2(0.8, 0.8)
	_panel.modulate.a = 0.0
	_color_rect.modulate.a = 0.0

	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)

	tween.tween_property(_panel, "scale", Vector2(1.0, 1.0), scale_duration)
	tween.tween_property(_panel, "modulate:a", 1.0, scale_duration)
	tween.tween_property(_color_rect, "modulate:a", blur_alpha, scale_duration)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().root.set_input_as_handled()
		_on_back_pressed()

func _on_back_pressed() -> void:
	_fade_out_and_close()

func _fade_out_and_close() -> void:
	if _animating:
		return
	_animating = true

	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)

	tween.tween_property(_panel, "modulate:a", 0.0, FADE_OUT_DURATION)
	tween.tween_property(_color_rect, "modulate:a", 0.0, FADE_OUT_DURATION)

	await tween.finished
	queue_free()
