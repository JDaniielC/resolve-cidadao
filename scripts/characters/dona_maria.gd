# scripts/characters/dona_maria.gd
extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
var can_interact = false

func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)
	animated_sprite.play("Default")

func _on_interaction_area_body_entered(body):
	if body.name == "Player":
		can_interact = true
		body.set_npc_proximity(self)
		if GameManager.current_stage == 1:
			GameManager.advance_stage()
		print("Player entered interaction range with Dona Maria - Stage now: %d" % GameManager.current_stage)

func _on_interaction_area_body_exited(body):
	if body.name == "Player":
		can_interact = false
		body.set_npc_proximity(null)
		print("Player left interaction range")

func is_player_near() -> bool:
	return can_interact

func trigger_dialogue():
	var dialogue_resource = load("res://dialogues/missao_01/dona_maria.dialogue")
	if GameManager.current_stage == 2:
		print("Dona Maria: Starting initial dialogue (Stage %d)" % GameManager.current_stage)
		DialogueManager.show_dialogue_balloon(dialogue_resource, "intro")
	elif GameManager.current_stage in [3, 4, 5]:
		print("Dona Maria: Starting waiting dialogue (Stage %d)" % GameManager.current_stage)
		DialogueManager.show_dialogue_balloon(dialogue_resource, "espera")
	elif GameManager.current_stage == 6:
		print("Dona Maria: Starting post-resolution dialogue (Stage %d)" % GameManager.current_stage)
		DialogueManager.show_dialogue_balloon(dialogue_resource, "pos_resolucao")
	else:
		print("Dona Maria: Current stage: %d (no dialogue)" % GameManager.current_stage)

func _on_dialogue_finished(_resource):
	if GameManager.current_stage == 2:
		print("Dona Maria: Initial dialogue finished, advancing stage...")
		GameManager.advance_stage()
	elif GameManager.current_stage == 6:
		print("Dona Maria: Post-resolution dialogue finished, advancing stage to end...")
		GameManager.advance_stage()
