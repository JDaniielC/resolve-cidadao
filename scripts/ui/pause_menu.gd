extends CanvasLayer
## PauseMenu overlay with blur, panel scale-in, and button interactions
## Manages pause state with smooth animations and ESC key support

class_name PauseMenu

## Animation timing
@export var scale_duration: float = 0.3
@export var fade_out_duration: float = 0.2

## Fade-out animation duration (used by _fade_out_and_execute helper)
const FADE_OUT_DURATION: float = 0.5

## Blur overlay alpha value
@export var blur_alpha: float = 0.7

## Internal state
var _panel: Panel
var _color_rect: ColorRect
var _buttons: Dictionary = {}
var _animating: bool = false


func _ready() -> void:
	# Set layer to ensure it appears above game
	layer = 100

	# Get node references
	_panel = $Control/Panel
	_color_rect = $Control/ColorRect

	# Validate node references
	if not _panel:
		push_error("PauseMenu: Panel node not found!")
		return
	if not _color_rect:
		push_error("PauseMenu: ColorRect node not found!")
		return

	# Setup button references and connections
	_buttons["resume"] = $Control/Panel/VBoxContainer/ButtonsContainer/ResumeButton
	_buttons["settings"] = $Control/Panel/VBoxContainer/ButtonsContainer/SettingsButton
	_buttons["menu"] = $Control/Panel/VBoxContainer/ButtonsContainer/MenuButton
	_buttons["quit"] = $Control/Panel/VBoxContainer/ButtonsContainer/QuitButton

	# Validate button references
	for button_key in _buttons.keys():
		if not _buttons[button_key]:
			push_error("PauseMenu: Button '%s' not found!" % button_key)
			return

	# Setup animations
	_setup_animations()

	# Connect button signals
	_connect_buttons()

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


func _connect_buttons() -> void:
	_buttons["resume"].pressed.connect(_on_resume_pressed)
	_buttons["settings"].pressed.connect(_on_settings_pressed)
	_buttons["menu"].pressed.connect(_on_menu_pressed)
	_buttons["quit"].pressed.connect(_on_quit_pressed)


func _input(event: InputEvent) -> void:
	# Handle ESC key or ui_cancel for immediate resume without animation
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().root.set_input_as_handled()
		MenuController.toggle_pause()
		queue_free()


func _on_resume_pressed() -> void:
	_fade_out_and_execute(func(): MenuController.toggle_pause(); queue_free())


func _on_settings_pressed() -> void:
	var settings_menu = preload("res://scenes/ui/menus/settings_menu.tscn").instantiate()
	add_child(settings_menu)


func _on_menu_pressed() -> void:
	_fade_out_and_execute(func(): MenuController.load_scene("res://scenes/ui/menus/main_menu.tscn"))


func _on_quit_pressed() -> void:
	_fade_out_and_execute(func(): MenuController.quit_game())


## Helper method to handle fade-out animation and execute callback
func _fade_out_and_execute(callback: Callable) -> void:
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

	# Execute callback after animation finishes
	await tween.finished
	callback.call()
