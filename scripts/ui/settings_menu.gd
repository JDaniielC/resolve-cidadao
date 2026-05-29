extends CanvasLayer
## SettingsMenu placeholder with animations and basic button interaction
## Manages settings with smooth fade-in and fade-out animations
##
## No `class_name` here: the functional settings menu in
## scripts/settings_menu.gd already registers the global `SettingsMenu`
## class, and two scripts cannot share one global class name.

## Animation timing
@export var scale_duration: float = 0.3
@export var fade_out_duration: float = 0.2

## Fade-out animation duration
const FADE_OUT_DURATION: float = 0.5

## Blur overlay alpha value
@export var blur_alpha: float = 0.7

## Internal state
var _panel: Panel
var _color_rect: ColorRect
var _back_button: Button
var _animating: bool = false


func _ready() -> void:
	# Set layer to ensure it appears above other menus
	layer = 101

	# Get node references
	_panel = $Control/Panel
	_color_rect = $Control/ColorRect
	_back_button = $Control/Panel/VBoxContainer/BackButton

	# Validate node references
	if not _panel:
		push_error("SettingsMenu: Panel node not found!")
		return
	if not _color_rect:
		push_error("SettingsMenu: ColorRect node not found!")
		return
	if not _back_button:
		push_error("SettingsMenu: BackButton node not found!")
		return

	# Setup animations
	_setup_animations()

	# Connect button signals
	_back_button.pressed.connect(_on_back_pressed)

	# Enable mouse interaction
	get_tree().root.gui_embed_subwindows = true


func _setup_animations() -> void:
	# Reset panel to initial state
	_panel.scale = Vector2(0.8, 0.8)
	_panel.modulate.a = 0.0
	_color_rect.modulate.a = 0.0

	# Create tween for scale-in and fade-in in parallel
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)

	tween.tween_property(_panel, "scale", Vector2(1.0, 1.0), scale_duration)
	tween.tween_property(_panel, "modulate:a", 1.0, scale_duration)
	tween.tween_property(_color_rect, "modulate:a", blur_alpha, scale_duration)


func _input(event: InputEvent) -> void:
	# Handle ESC key or ui_cancel for immediate close without animation
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().root.set_input_as_handled()
		_on_back_pressed()


func _on_back_pressed() -> void:
	_fade_out_and_close()


## Helper method to handle fade-out animation and close menu
func _fade_out_and_close() -> void:
	if _animating:
		return

	_animating = true

	# Fade out the UI with parallel animations
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)

	tween.tween_property(_panel, "modulate:a", 0.0, FADE_OUT_DURATION)
	tween.tween_property(_color_rect, "modulate:a", 0.0, FADE_OUT_DURATION)

	# Queue free after animation finishes
	await tween.finished
	queue_free()
