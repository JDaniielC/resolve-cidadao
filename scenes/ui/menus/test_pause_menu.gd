extends Node
## Test scene for PauseMenu - can be run directly to test the pause menu

func _ready() -> void:
	print("[TestPauseMenu] Scene loaded. Press ESC to test pause resume.")
	print("[TestPauseMenu] Click buttons to test interactions.")

func _input(event: InputEvent) -> void:
	# Allow pressing P to test the pause menu creation
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		print("[TestPauseMenu] P pressed - PauseMenu should be visible in the scene tree")
