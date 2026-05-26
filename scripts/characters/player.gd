# scripts/characters/player.gd
extends CharacterBody2D

const SPEED = 150.0
var direction = Vector2.ZERO

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Input
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func get_player_position() -> Vector2:
	return global_position

var is_near_npc = false

func set_npc_proximity(value: bool):
	is_near_npc = value

func _input(event):
	if event.is_action_pressed("interact") and is_near_npc:
		print("Player pressed interact near NPC")
		get_tree().root.get_node("MainGame/DonaMariam").trigger_dialogue()
