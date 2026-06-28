# scripts/characters/seu_severino.gd
extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
var can_interact = false
var _quiz_shown := false
var _conversa_final_done := false

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

	_update_dialogue_title()
	GameManager.stage_changed.connect(func(_s): _update_dialogue_title())

func _on_interaction_entered(node):
	if node and node.is_in_group("player"):
		can_interact = true
		node.set_npc_proximity(self)
		_update_dialogue_title()

func _on_interaction_exited(node):
	if node and node.is_in_group("player"):
		can_interact = false
		node.set_npc_proximity(null)

func is_player_near() -> bool:
	return can_interact

func trigger_dialogue():
	pass

func _update_dialogue_title():
	var dialogue_state = get_node_or_null("StateMachine/start_dialogue")
	if not dialogue_state:
		return
	match GameManager.current_stage:
		14:
			dialogue_state.title = "intro"
		15:
			if GameManager.get("radio_collected"):
				dialogue_state.title = "conversa_final"
			else:
				dialogue_state.title = "aguardando_radio"
		16:
			# Stage 16 = jogador voltou após pegar o rádio
			dialogue_state.title = "conversa_final"
		17:
			dialogue_state.title = "obrigado"

func _on_dialogue_finished(resource):
	if not (resource and resource.resource_path.ends_with("seu_severino.dialogue")):
		return

	if GameManager.current_stage == 14 and not _quiz_shown:
		# Terminou "intro" → quiz de abordagem
		# ChoicePanel avança stage 14 → 15 ao acertar
		_quiz_shown = true
		var choice_panel = _get_choice_panel()
		if choice_panel:
			choice_panel.show_choice("severino_approach")
		else:
			push_error("[SeuSeverino] ChoicePanel não encontrado.")

	elif GameManager.current_stage == 16 and not _conversa_final_done:
		# Terminou "conversa_final" → agora abre o quiz da Defesa Civil
		_conversa_final_done = true
		await get_tree().create_timer(0.5).timeout
		_start_phone_challenge()

func _start_phone_challenge():
	var phone = _get_phone_menu()
	if not phone:
		push_error("[SeuSeverino] PhoneMenu não encontrado.")
		return
	phone.start_contact_challenge(
		"defesa_civil",
		"Seu Severino precisa de resgate! Qual órgão você deve acionar?"
	)
	await phone.contact_challenge_succeeded
	Notifications.notify_sms(
		"Defesa Civil — 199",
		"Resgate confirmado. Equipe a caminho. Dirija-se ao Abrigo Municipal na Escola Pública."
	)
	await get_tree().create_timer(1.0).timeout
	GameManager.advance_stage()   # 16 → 17
	_update_dialogue_title()

func _get_choice_panel() -> Control:
	var panel = get_tree().root.get_node_or_null("MainGame/UILayer/ChoicePanel")
	if panel:
		return panel
	return get_tree().current_scene.get_node_or_null("UILayer/ChoicePanel")

func _get_phone_menu() -> Control:
	var phone = get_tree().root.get_node_or_null("MainGame/UILayer/PhoneMenu")
	if phone:
		return phone
	return get_tree().current_scene.get_node_or_null("UILayer/PhoneMenu")
