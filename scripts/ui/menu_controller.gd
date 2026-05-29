extends Node
## Global menu controller singleton for pause state and scene transitions.
##
## Accessible globally via the `MenuController` autoload (registered in
## project.godot). It must NOT also declare `class_name MenuController`,
## as that name would collide with the autoload singleton.
##
## Settings persistence lives in UserPrefs (scripts/user_prefs.gd), applied via
## the Globals autoload. This controller intentionally does NOT store settings.

# Emitted whenever the game is paused or resumed.
signal menu_state_changed(paused: bool)

# Pause state
var _is_paused: bool = false

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

## Toggle pause state and emit signal
func toggle_pause() -> void:
	_is_paused = !_is_paused
	get_tree().paused = _is_paused
	menu_state_changed.emit(_is_paused)
	push_log("Game %s" % ("paused" if _is_paused else "resumed"))

## Check if game is currently paused
func is_paused() -> bool:
	return _is_paused

## Set pause state directly
func set_paused(paused: bool) -> void:
	if _is_paused == paused:
		return
	_is_paused = paused
	get_tree().paused = paused
	menu_state_changed.emit(paused)
	push_log("Game %s" % ("paused" if _is_paused else "resumed"))

## Load a new scene (unpauses game if paused)
func load_scene(scene_path: String) -> void:
	if _is_paused:
		toggle_pause()

	get_tree().change_scene_to_file(scene_path)
	push_log("Loading scene %s" % scene_path)

## Quit the game
func quit_game() -> void:
	push_log("Quitting game")
	get_tree().quit()

## Helper function for consistent logging
func push_log(message: String) -> void:
	print("[MenuController] %s" % message)
