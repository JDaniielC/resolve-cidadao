# scripts/characters/dona_maria.gd
extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
var can_interact = false

func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)
	animated_sprite.play("Default")
	
	var interaction_area = $InteractionArea
	if interaction_area:
		interaction_area.body_entered.connect(func(body): _on_interaction_entered(body))
		interaction_area.body_exited.connect(func(body): _on_interaction_exited(body))
		interaction_area.area_entered.connect(func(area): _on_interaction_entered(area.get_parent()))
		interaction_area.area_exited.connect(func(area): _on_interaction_exited(area.get_parent()))
		print("Dona Maria: InteractionArea signals successfully connected in code.")
		
	_update_dialogue_title()
	GameManager.stage_changed.connect(func(_new_stage): _update_dialogue_title())

	# Ao continuar de um save parado no stage 3, reexibe a escolha (que normalmente
	# aparece na transição 2->3).
	if GameManager.current_stage == 3:
		_show_need_choice.call_deferred()

func _on_interaction_entered(node):
	if node and node.is_in_group("player"):
		can_interact = true
		node.set_npc_proximity(self)
		if GameManager.current_stage == 1:
			GameManager.advance_stage()
		_update_dialogue_title()
		print("Player entered interaction range with Dona Maria - Stage now: %d" % GameManager.current_stage)

func _on_interaction_exited(node):
	if node and node.is_in_group("player"):
		can_interact = false
		node.set_npc_proximity(null)
		print("Player left interaction range")

func is_player_near() -> bool:
	return can_interact

func trigger_dialogue():
	pass

func _update_dialogue_title():
	var dialogue_state = get_node_or_null("StateMachine/start_dialogue")
	if dialogue_state:
		if GameManager.current_stage == 2:
			dialogue_state.title = "intro"
		elif GameManager.current_stage in [3, 4, 5]:
			dialogue_state.title = "espera"
		elif GameManager.current_stage == 6:
			dialogue_state.title = "pos_abrigo"
		elif GameManager.current_stage == 9:
			dialogue_state.title = "rua_destruida"
			Notifications.notify_problem("Danos estruturais graves identificados no bairro.", "🏠")
		elif GameManager.current_stage == 10:
			dialogue_state.title = "espera_agente"
		elif GameManager.current_stage == 11:
			if GameManager.housing_solved:
				dialogue_state.title = "pos_final"
			else:
				dialogue_state.title = "final"
				
		elif GameManager.current_stage == 12:
			dialogue_state.title = "pos_gatilho"	
			
		print("Dona Maria: Updated StateMachine dialogue state title to: ", dialogue_state.title)

	var marker = get_node_or_null("MissionMarker")
	if marker:
		if GameManager.current_stage in [1, 2]:
			marker.visible_at_stage = GameManager.current_stage
		elif GameManager.current_stage == 9:
			marker.visible_at_stage = 9
		elif GameManager.current_stage == 11:
			marker.visible_at_stage = 11
		else:
			marker.visible_at_stage = -1
		if marker.has_method("_update_visibility"):
			marker._update_visibility(GameManager.current_stage)

func _show_need_choice() -> void:
	var choice_panel = get_tree().root.get_node_or_null("MainGame/UILayer/ChoicePanel")
	if choice_panel:
		choice_panel.show_choice("choice_housing")
	else:
		push_error("Dona Maria: ChoicePanel not found after intro dialogue.")

func _show_moradia_choice() -> void:
	var choice_panel = get_tree().root.get_node_or_null("MainGame/UILayer/ChoicePanel")
	if choice_panel:
		choice_panel.show_choice("choice_moradia_comprometida")
	else:
		push_error("Dona Maria: ChoicePanel not found after rua_destruida dialogue.")

func _on_dialogue_finished(_resource):
	if _resource and _resource.resource_path.ends_with("dona_maria.dialogue"):
		if GameManager.current_stage == 2:
			print("Dona Maria: Intro dialogue finished, advancing to need identification...")
			GameManager.advance_stage()
			_show_need_choice()
			_update_dialogue_title()
		elif GameManager.current_stage == 6:
			print("Dona Maria: Pre-shelter hint dialogue finished.")
		elif GameManager.current_stage == 9:
			print("Dona Maria: Destructed street dialogue finished. Advancing stage to 10...")
			GameManager.advance_stage()
			_update_dialogue_title()
		elif GameManager.current_stage == 11 and not GameManager.assessment_completed:
			print("Dona Maria: Final dialogue finished. Starting assessment flow...")
			GameManager.housing_solved = true
			GameManager.resolve_problem("Moradia — Aluguel Social", 15.0)

			var main_game := _find_main_game()
			if main_game and main_game.has_method("begin_mission_wrap_up"):
				main_game.call_deferred("begin_mission_wrap_up")
				
				var mission_complete = main_game.get_node_or_null("MissionComplete")
				if mission_complete:
					await mission_complete.closed
					
				var dialogue_res = load("res://dialogues/missao_01/dona_maria.dialogue")
				DialogueManager.show_example_dialogue_balloon(dialogue_res, "gatilho_missao2")
			else:
				push_error("Dona Maria: MainGame controller not found for mission wrap-up.")
				
		elif GameManager.current_stage == 11 and GameManager.assessment_completed:
			# Notificação de nova missão no celular 
			Notifications.notify_sms(
				"Nova missão!",
				"NOVA MISSÃO: Teimosia que Salva — Suba em direção à encosta e procure por Lucas."
			)
			
			GameManager.advance_stage()
			_update_dialogue_title()

func _find_main_game() -> Node:
	var node: Node = self
	while node:
		if node.has_method("begin_mission_wrap_up"):
			return node
		node = node.get_parent()
	return get_tree().root.get_node_or_null("MainGame")
