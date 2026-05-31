extends Area2D

@export var target_scene := "res://scenes/levels/shelter.tscn"

var player_inside := false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body is PlayerEntity:
		player_inside = true

func _on_body_exited(body):
	if body is PlayerEntity:
		player_inside = false

func _process(_delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		MenuController.load_scene(target_scene)
