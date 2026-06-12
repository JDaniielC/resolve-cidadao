extends Area2D

@export var target_scene := "res://scenes/levels/shelter.tscn"
@export var required_stage: int = 7

var _transition_started := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or _transition_started:
		return
	if GameManager.current_stage < required_stage:
		print("[Area2D] School door locked. Current stage: %d, required: %d" % [GameManager.current_stage, required_stage])
		return

	var main_game := get_tree().current_scene
	var current_level := main_game.get_node_or_null("RayScene")
	if current_level == null:
		push_error("[Area2D] Could not find level node to swap.")
		return

	_transition_started = true
	print("[Area2D] Player entered school area. Transitioning to: %s" % target_scene)
	if main_game.has_method("swap_level"):
		main_game.swap_level.call_deferred(target_scene, current_level)
