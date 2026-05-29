extends Control

class_name MainMenu

## Animation configuration
const TITLE_FADE_DURATION: float = 0.3
const BUTTON_FADE_DURATION: float = 0.2
const BUTTON_STAGGER_DELAY: float = 0.1
const FADE_OUT_DURATION: float = 0.5

## Node references
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var buttons_container: VBoxContainer = $VBoxContainer/ButtonsContainer
@onready var play_button: Button = $VBoxContainer/ButtonsContainer/PlayButton
@onready var settings_button: Button = $VBoxContainer/ButtonsContainer/SettingsButton
@onready var credits_button: Button = $VBoxContainer/ButtonsContainer/CreditsButton
@onready var quit_button: Button = $VBoxContainer/ButtonsContainer/QuitButton


func _ready() -> void:
	_setup_animations()
	_connect_buttons()


## Setup fade-in animations for title and buttons
func _setup_animations() -> void:
	# Title fade-in (0 → 1.0 alpha, 0.3s)
	title_label.modulate.a = 0.0
	var title_tween: Tween = create_tween()
	title_tween.tween_property(title_label, "modulate:a", 1.0, TITLE_FADE_DURATION)

	# Buttons stagger fade-in: each button appears with 100ms delay
	var buttons: Array[Button] = [play_button, settings_button, credits_button, quit_button]

	for button: Button in buttons:
		button.modulate.a = 0.0

	for i: int in range(buttons.size()):
		var button: Button = buttons[i]
		var delay: float = i * BUTTON_STAGGER_DELAY
		await get_tree().create_timer(delay).timeout
		var fade_tween: Tween = create_tween()
		fade_tween.tween_property(button, "modulate:a", 1.0, BUTTON_FADE_DURATION)


## Connect button signals to their respective callbacks
func _connect_buttons() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


## Handle Play button press
func _on_play_pressed() -> void:
	_fade_out_and_load("res://scenes/main_game.tscn")


## Handle Settings button press
func _on_settings_pressed() -> void:
	var settings_menu = preload("res://scenes/ui/menus/settings_menu.tscn").instantiate()
	add_child(settings_menu)


## Handle Credits button press
func _on_credits_pressed() -> void:
	pass


## Handle Quit button press
func _on_quit_pressed() -> void:
	_fade_out_and_quit()


## Helper: fade out and execute callback
func _fade_out_and_do(callback: Callable) -> void:
	var fade_tween: Tween = create_tween()
	fade_tween.set_ease(Tween.EASE_IN)
	fade_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT_DURATION)
	fade_tween.tween_callback(callback)


## Fade out and load a new scene
func _fade_out_and_load(scene_path: String) -> void:
	_fade_out_and_do(func() -> void:
		MenuController.load_scene(scene_path)
	)


## Fade out and quit the game
func _fade_out_and_quit() -> void:
	_fade_out_and_do(func() -> void:
		MenuController.quit_game()
	)
