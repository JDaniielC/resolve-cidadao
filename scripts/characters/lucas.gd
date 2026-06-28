# scripts/characters/lucas.gd
extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
var can_interact = false

func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)
	if animated_sprite:
		animated_sprite.play("Default")

	var interaction_area = $InteractionArea
	if interaction_area:
		interaction_area.body_entered.connect(func(body): _on_interaction_entered(body))
		interaction_area.body_exited.connect(func(body): _on_interaction_exited(body))
		interaction_area.area_entered.connect(func(area): _on_interaction_entered(area.get_parent()))
		interaction_area.area_exited.connect(func(area): _on_interaction_exited(area.get_parent()))

	_update_visibility()
	_update_dialogue_title()
	GameManager.stage_changed.connect(func(_s): _update_visibility(); _update_dialogue_title())

func _on_interaction_entered(node):
	if node and node.is_in_group("player"):
		can_interact = true
		node.set_npc_proximity(self)
		# Stage 12: jogador chegou perto de Lucas pela primeira vez → avança
		if GameManager.current_stage == 12:
			GameManager.advance_stage()  # 12 → 13
		_update_dialogue_title()

func _on_interaction_exited(node):
	if node and node.is_in_group("player"):
		can_interact = false
		node.set_npc_proximity(null)

func is_player_near() -> bool:
	return can_interact

func trigger_dialogue():
	pass

func _update_visibility():
	# Lucas aparece a partir do stage 12 (quando a missão 2 começa)
	var active = GameManager.current_stage >= 12
	visible = active
	var col = get_node_or_null("CollisionShape2D")
	if col:
		col.disabled = not active
	var area_col = get_node_or_null("InteractionArea/CollisionShape2D")
	if area_col:
		area_col.disabled = not active

func _update_dialogue_title():
	var dialogue_state = get_node_or_null("StateMachine/start_dialogue")
	if not dialogue_state:
		return
	if GameManager.current_stage == 13:
		# Jogador chegou até Lucas → diálogo principal
		dialogue_state.title = "intro"
	elif GameManager.current_stage >= 14:
		# Já conversou → frase curta de encorajamento
		dialogue_state.title = "espera"

func _on_dialogue_finished(_resource):
	if not (_resource and _resource.resource_path.ends_with("lucas.dialogue")):
		return
	if GameManager.current_stage == 13:
		# Lucas terminou de contar sobre o avô → avança para ir falar com Severino
		GameManager.advance_stage()  # 13 → 14
		_update_dialogue_title()
