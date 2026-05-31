extends Area2D

@export var target_scene := "res://scenes/levels/shelter.tscn"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("[Area2D] Player entered school area. Transitioning automatically to: %s" % target_scene)
		MenuController.load_scene(target_scene)

