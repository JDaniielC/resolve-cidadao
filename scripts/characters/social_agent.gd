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
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)
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

func is_player_near() -> bool:
	return can_interact

func trigger_dialogue():
	# Carrega o recurso de diálogo
	var dialogue_resource = load("res://dialogues/agente_social.dialogue")
	# Chama o DialogueManager (Autoload global do addon) para mostrar o balão
	if dialogue_resource:
		var target_title = "start"
		if GameManager.current_stage >= 11:
			target_title = "espera"
		DialogueManager.show_example_dialogue_balloon(dialogue_resource, target_title)
		print("SocialAgent: Dialogue started using DialogueManager.")

func _on_dialogue_finished(_resource):
	if _resource and _resource.resource_path.ends_with("agente_social.dialogue"):
		if GameManager.current_stage == 10:
			print("SocialAgent: Dialogue finished at stage 10. Showing ChoicePanel...")
			_show_moradia_choice()

func _show_moradia_choice() -> void:
	var choice_panel = get_tree().root.get_node_or_null("MainGame/UILayer/ChoicePanel")
	if not choice_panel:
		choice_panel = get_tree().current_scene.get_node_or_null("UILayer/ChoicePanel")
	if choice_panel:
		choice_panel.show_choice("choice_moradia_comprometida")
	else:
		push_error("SocialAgent: ChoicePanel not found after social agent dialogue.")

func _update_npc_state():
	# O NPC só deve ser interativo em estágios específicos (ex: Etapa 10)
	var active = GameManager.current_stage >= 10
	visible = active
	set_process(active)
	set_physics_process(active)
	
	var collision = get_node_or_null("CollisionShape2D")
	if collision:
		collision.disabled = not active
		
	var int_collision = get_node_or_null("InteractionArea/CollisionShape2D")
	if int_collision:
		int_collision.disabled = not active

	# Se desativar, limpa a interação caso o player esteja perto
	if not active:
		can_interact = false
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("set_npc_proximity") and player.nearby_npc == self:
			player.set_npc_proximity(null)
