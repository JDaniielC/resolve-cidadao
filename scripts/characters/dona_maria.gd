# scripts/characters/dona_maria.gd
extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
var can_interact = false

func _ready():
	DialogueSystem.dialogue_finished.connect(_on_dialogue_finished)
	animated_sprite.play("Default")

func _on_interaction_area_body_entered(body):
	if body.name == "Player":
		can_interact = true
		body.set_npc_proximity(true)
		if GameManager.current_stage == 1:
			GameManager.advance_stage()
		print("Player entered interaction range with Dona Maria")

func _on_interaction_area_body_exited(body):
	if body.name == "Player":
		can_interact = false
		body.set_npc_proximity(false)
		print("Player left interaction range")

func is_player_near() -> bool:
	return can_interact

func trigger_dialogue():
	if GameManager.current_stage == 2:
		DialogueSystem.start_dialogue("intro")

func _on_dialogue_finished(_dialogue_id: String):
	if _dialogue_id == "intro" and GameManager.current_stage == 2:
		GameManager.advance_stage()
