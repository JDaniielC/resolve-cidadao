extends Node2D
class_name PedestrianNPC

## --- Configurações ajustáveis no Inspector ---
@export var speed: float = 60.0           # velocidade em pixels/segundo (menor que o carro)
@export var wait_time: float = 3.0        # segundos parado entre passagens
@export var knockback_force: float = 180.0 # força de empurrão (menor que o carro)
@export var flip_on_return: bool = true   # inverte sprite quando vai da direita pra esquerda

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_area: Area2D = $HitArea

@onready var shape_hit: CollisionShape2D = $HitArea/CollisionShape2D

var _follow: PathFollow2D
var _running: bool = false
var _last_position: Vector2 = Vector2.ZERO
var _move_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	_follow = get_parent() as PathFollow2D
	if _follow == null:
		push_warning("PedestrianNPC precisa ser filho de um PathFollow2D.")
		return
	_follow.rotates = false

	if hit_area:
		hit_area.body_entered.connect(_on_hit_area_body_entered)

	_last_position = global_position
	_start_pass()

func _process(delta: float) -> void:
	if not _running or _follow == null:
		return

	# Avança ao longo do caminho
	_follow.progress += speed * delta

	# Atualiza direção de movimento
	var current_pos := global_position
	if current_pos != _last_position:
		_move_direction = (current_pos - _last_position).normalized()
	_last_position = current_pos

	# Y-sort manual
	z_index = int(global_position.y)

	# Flip do sprite conforme direção horizontal
	if flip_on_return:
		sprite.flip_h = _move_direction.x < 0.0

	# Chegou ao fim do caminho?
	if _follow.progress_ratio >= 1.0:
		_running = false
		_follow.progress_ratio = 1.0
		_wait_and_repeat()

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
	sprite.play("walk")

func _wait_and_repeat() -> void:
	visible = false
	sprite.stop()
	await get_tree().create_timer(wait_time).timeout
	_start_pass()
