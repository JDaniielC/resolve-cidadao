# scripts/characters/social_agent.gd
extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var interaction_area = $InteractionArea
@onready var state_machine = $StateMachine

var can_interact = false

func _ready():
	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_entered)
		interaction_area.body_exited.connect(_on_interaction_exited)
	
	_update_npc_state()
	GameManager.stage_changed.connect(func(_s): _update_npc_state())

func _on_interaction_entered(body):
	if body.is_in_group("player"):
		can_interact = true
		body.set_npc_proximity(self)

func _on_interaction_exited(body):
	if body.is_in_group("player"):
		can_interact = false
		body.set_npc_proximity(null)

func trigger_dialogue():
	# Carrega o recurso de diálogo
	var dialogue_resource = load("res://dialogues/agente_social.dialogue")
	# Chama o DialogueManager (Autoload global do addon) para mostrar o balão
	if dialogue_resource:
		DialogueManager.show_example_dialogue_balloon(dialogue_resource, "start")
		print("SocialAgent: Dialogue started using DialogueManager.")

func _update_npc_state():
	# O NPC só deve ser interativo em estágios específicos (ex: Etapa 10)
	# Se GameManager.current_stage < 10, poderíamos desabilitar a colisão ou esconder
	pass
