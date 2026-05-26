extends Node2D
## Controller script for MainGame scene that manages pause menu integration and input handling

# Preload pause menu scene
var pause_menu_scene = preload("res://scenes/ui/menus/pause_menu.tscn")

func _ready() -> void:
	# Connect to MenuController pause state signal
	MenuController.menu_state_changed.connect(_on_menu_state_changed)
	print("[MainGameController] Ready - pause menu integrated")

func _input(event: InputEvent) -> void:
	# Only handle ESC if game is not already paused
	if event.is_action_pressed("ui_cancel") and not MenuController.is_paused():
		_open_pause_menu()
		get_tree().root.set_input_as_handled()

func _open_pause_menu() -> void:
	## Open pause menu by toggling pause state and instantiating pause menu
	MenuController.toggle_pause()
	add_child(pause_menu_scene.instantiate())

func _on_menu_state_changed(is_paused: bool) -> void:
	## Handle menu state changes (pause/resume) to adjust input handling
	if is_paused:
		# Game paused - enable mouse interaction with menu
		Input.set_mouse_filter(Control.MOUSE_FILTER_STOP)
	else:
		# Game resumed - pass clicks to game
		Input.set_mouse_filter(Control.MOUSE_FILTER_PASS)
