# scripts/ui/mission_marker.gd
# Shows a pulsing arrow/indicator above an NPC to guide the player.
# Visible only while target stage matches. Auto-hides on approach.
extends Node2D

## The stage during which this marker should be visible.
@export var visible_at_stage: int = 1

## Hide when player is within this distance (pixels)
@export var hide_distance: float = 80.0

var _tween: Tween
var _player: Node2D = null

@onready var arrow_label: Label = $Arrow

func _ready() -> void:
	if arrow_label:
		arrow_label.text = "❗"
		EmojiFont.apply_to(arrow_label)
	add_to_group("mission_markers")
	GameManager.stage_changed.connect(_on_stage_changed)
	_update_visibility(GameManager.current_stage)
	_start_pulse()

func _process(_delta: float) -> void:
	if not visible:
		return
	# Hide when player gets close
	if not _player:
		_player = get_tree().get_first_node_in_group("player")
	if _player:
		var dist := global_position.distance_to(_player.global_position)
		if dist < hide_distance:
			visible = false
		elif GameManager.current_stage == visible_at_stage:
			visible = true

func _on_stage_changed(new_stage: int) -> void:
	_update_visibility(new_stage)

func _update_visibility(stage: int) -> void:
	visible = (stage == visible_at_stage)
	if visible:
		_start_pulse()

func _start_pulse() -> void:
	if _tween:
		_tween.kill()
	if not arrow_label:
		return
	arrow_label.scale = Vector2.ONE
	_tween = create_tween().set_loops()
	_tween.tween_property(arrow_label, "position:y", -14.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(arrow_label, "position:y", -6.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
