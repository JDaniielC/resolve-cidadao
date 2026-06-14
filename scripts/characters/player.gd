# scripts/characters/player.gd
extends CharacterBody2D

const SPEED = 150.0

# Controle do empurrão (knockback)
const KNOCKBACK_RECOVERY = 800.0  # Quão rápido o empurrão "desliga"
var knockback_velocity = Vector2.ZERO

var direction = Vector2.ZERO

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Input
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED
	else:
		velocity = Vector2.ZERO

	# Aplica o empurrão (se houver)
	if knockback_velocity.length() > 0:
		velocity += knockback_velocity
		# Reduz o empurrão suavemente até zerar
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_RECOVERY * delta)

	move_and_slide()

# Função chamada pelo carro quando atropela o player
func apply_knockback(push_direction: Vector2, force: float) -> void:
	knockback_velocity = push_direction.normalized() * force

func get_player_position() -> Vector2:
	return global_position

var is_near_npc = false

func set_npc_proximity(value: bool):
	is_near_npc = value

func _input(event):
	if event.is_action_pressed("interact") and is_near_npc:
		print("Player pressed interact near NPC")
		get_tree().root.get_node("MainGame/DonaMariam").trigger_dialogue()
