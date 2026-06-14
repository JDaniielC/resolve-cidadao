extends Node2D
class_name CarNPC

@export var speed: float = 120.0
@export var wait_time: float = 5.0

@export var texture_side: Texture2D
@export var texture_front: Texture2D

@export_range(0.0, 1.0) var curve_threshold: float = 0.5
@export var flip_side: bool = false
@export var knockback_force: float = 400.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_area: Area2D = $HitArea
@onready var hit_area2: Area2D = $HitArea2

# Pega o CollisionShape2D dentro de cada Area2D
@onready var shape_side: CollisionShape2D = $HitArea/CollisionShape2D
@onready var shape_front: CollisionShape2D = $HitArea2/CollisionShape2D

var _follow: PathFollow2D
var _running: bool = false
var _last_position: Vector2 = Vector2.ZERO
var _move_direction: Vector2 = Vector2.RIGHT
var _is_front: bool = false

func _ready() -> void:
	_follow = get_parent() as PathFollow2D
	if _follow == null:
		push_warning("CarNPC precisa ser filho de um PathFollow2D.")
		return
	_follow.rotates = false

	if hit_area:
		hit_area.body_entered.connect(_on_hit_area_body_entered)
	if hit_area2:
		hit_area2.body_entered.connect(_on_hit_area_body_entered)

	_last_position = global_position
	_start_pass()

func _process(delta: float) -> void:
	if not _running or _follow == null:
		return

	_follow.progress += speed * delta

	var current_pos := global_position
	if current_pos != _last_position:
		_move_direction = (current_pos - _last_position).normalized()
	_last_position = current_pos

	z_index = int(global_position.y)

	var should_be_front := _follow.progress_ratio >= curve_threshold
	if should_be_front != _is_front:
		_is_front = should_be_front
		_update_appearance(should_be_front)

	if _follow.progress_ratio >= 1.0:
		_running = false
		_follow.progress_ratio = 1.0
		_wait_and_repeat()

func _update_appearance(is_front: bool) -> void:
	if is_front:
		if sprite:
			sprite.texture = texture_front
			sprite.flip_h = false
		# desliga o de lado, liga o de frente
		shape_side.set_deferred("disabled", true)
		shape_front.set_deferred("disabled", false)
	else:
		if sprite:
			sprite.texture = texture_side
			sprite.flip_h = flip_side
		shape_side.set_deferred("disabled", false)
		shape_front.set_deferred("disabled", true)

func _on_hit_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("apply_knockback"):
		var forward: Vector2 = _move_direction
		var to_player: Vector2 = (body.global_position - global_position).normalized()
		var lateral: Vector2 = to_player - forward * to_player.dot(forward)
		lateral = lateral.normalized()
		var push_dir: Vector2 = (forward * 0.5 + lateral * 0.8).normalized()
		body.apply_knockback(push_dir, knockback_force)

func _start_pass() -> void:
	_follow.progress_ratio = 0.0
	_running = true
	visible = true
	_is_front = false
	_update_appearance(false)

func _wait_and_repeat() -> void:
	visible = false
	await get_tree().create_timer(wait_time).timeout
	_start_pass()
