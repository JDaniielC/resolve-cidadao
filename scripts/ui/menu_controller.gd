extends Node
## Global menu controller singleton for managing game state, settings, and scene transitions.
## Handles pause state, settings persistence, and scene loading.
##
## Accessible globally via the `MenuController` autoload (registered in
## project.godot). It must NOT also declare `class_name MenuController`,
## as that name would collide with the autoload singleton.

# Signals for menu state changes
signal menu_state_changed(paused: bool)
signal settings_changed(setting_key: String, value: Variant)

# Default settings constant
const DEFAULT_SETTINGS: Dictionary = {
	"sfx_volume": 1.0,
	"music_volume": 1.0,
	"brightness": 1.0,
	"language": "pt"
}

# Settings storage
var _settings: Dictionary = {}
var _config: ConfigFile = ConfigFile.new()
var _settings_path: String = "user://settings.cfg"

# Pause state
var _is_paused: bool = false

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	load_settings()

## Load settings from user://settings.cfg
## Creates default settings if file doesn't exist
func load_settings() -> void:
	var error: Error = _config.load(_settings_path)

	# Initialize default settings if file doesn't exist
	if error != OK:
		_settings = DEFAULT_SETTINGS.duplicate()
	else:
		# Load from config file
		_settings = {
			"sfx_volume": _config.get_value("settings", "sfx_volume", DEFAULT_SETTINGS["sfx_volume"]),
			"music_volume": _config.get_value("settings", "music_volume", DEFAULT_SETTINGS["music_volume"]),
			"brightness": _config.get_value("settings", "brightness", DEFAULT_SETTINGS["brightness"]),
			"language": _config.get_value("settings", "language", DEFAULT_SETTINGS["language"])
		}

	push_log("MenuController: Loaded settings from %s" % _settings_path)

## Save all settings to user://settings.cfg
func save_settings() -> void:
	for key: String in _settings.keys():
		_config.set_value("settings", key, _settings[key])

	var error: Error = _config.save(_settings_path)
	if error != OK:
		push_error("MenuController: Failed to save settings. Error: %s" % error)
	else:
		push_log("MenuController: Settings saved successfully to %s" % _settings_path)

## Toggle pause state and emit signal
func toggle_pause() -> void:
	_is_paused = !_is_paused
	get_tree().paused = _is_paused
	menu_state_changed.emit(_is_paused)
	push_log("MenuController: Game %s" % ("paused" if _is_paused else "resumed"))

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
	push_log("MenuController: Game %s" % ("paused" if _is_paused else "resumed"))

## Load a new scene (unpauses game if paused)
func load_scene(scene_path: String) -> void:
	if _is_paused:
		toggle_pause()

	get_tree().change_scene_to_file(scene_path)
	push_log("MenuController: Loading scene %s" % scene_path)

## Quit the game
func quit_game() -> void:
	save_settings()
	push_log("MenuController: Quitting game")
	get_tree().quit()

## Get a setting value by key
func get_setting(key: String) -> Variant:
	if _settings.has(key):
		return _settings[key]
	else:
		push_warning("MenuController: Setting key '%s' not found" % key)
		return null

## Set a setting value by key
func set_setting(key: String, value: Variant) -> void:
	if not _settings.has(key):
		push_warning("MenuController: Setting key '%s' not found" % key)
		return

	# Validate and clamp numeric settings
	if key in ["sfx_volume", "music_volume", "brightness"]:
		if not value is float and not value is int:
			push_warning("MenuController: Setting '%s' must be a number" % key)
			return
		value = float(clamp(float(value), 0.0, 1.0))

	_settings[key] = value
	settings_changed.emit(key, value)
	push_log("MenuController: Setting '%s' updated to %s" % [key, value])

## Get all current settings
func get_all_settings() -> Dictionary:
	return _settings.duplicate()

## Helper function for consistent logging
func push_log(message: String) -> void:
	print("[MenuController] %s" % message)
