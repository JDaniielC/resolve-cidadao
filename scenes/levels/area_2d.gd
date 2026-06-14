extends Area2D

@export_file("*.tscn") var target_scene: String
@export var required_stage: int = 0
@export var auto_advance_from_stage: int = -1 # Set to a stage number (e.g. 6) to automatically advance the stage when entering

var _transition_started := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or _transition_started:
		return
	
	if auto_advance_from_stage >= 0 and GameManager.current_stage == auto_advance_from_stage:
		print("[Area2D] Player reached transition area at stage %d, advancing stage..." % auto_advance_from_stage)
		GameManager.advance_stage()
		
	if GameManager.current_stage < required_stage:
		print("[Area2D] Transition locked. Current stage: %d, required: %d" % [GameManager.current_stage, required_stage])
		return

	var main_game := get_tree().current_scene
	
	# Find the current level node dynamically (it's the direct child of main_game that contains this Area2D)
	var current_level: Node = self
	while current_level != null and current_level.get_parent() != main_game:
		current_level = current_level.get_parent()
		
	if current_level == null:
		push_error("[Area2D] Could not find the level root node to swap.")
		return

	_transition_started = true
	print("[Area2D] Player entered transition area. Transitioning from %s to: %s" % [current_level.name, target_scene])
	if main_game.has_method("swap_level"):
		main_game.swap_level.call_deferred(target_scene, current_level)
