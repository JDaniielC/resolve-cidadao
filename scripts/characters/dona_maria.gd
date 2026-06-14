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
		elif GameManager.current_stage == 11:
			dialogue_state.title = "final"
		print("Dona Maria: Updated StateMachine dialogue state title to: ", dialogue_state.title)

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
			print("Dona Maria: Destructed street dialogue finished. Showing choice...")
			_show_moradia_choice()
		elif GameManager.current_stage == 10:
			print("Dona Maria: Aluguel social orientation dialogue finished. Opening phone to explain concept...")
			GameManager.housing_solved = true
			
			var main_game = get_tree().current_scene
			var phone = main_game.get_node_or_null("UILayer/PhoneMenu")
			if not phone:
				phone = get_tree().root.find_child("PhoneMenu", true, false)
			if phone:
				var phone_wrapper = phone.get_parent()
				if phone_wrapper and phone_wrapper is CanvasLayer:
					phone_wrapper.visible = true
				phone.visible = true
				phone._show_screen("concepts")
				phone._show_aluguel_social_detail()
			_update_dialogue_title()
		elif GameManager.current_stage == 11:
			print("Dona Maria: Final thank you dialogue finished. Completing mission and adding satisfaction!")
			GameManager.add_satisfaction(15.0)
			
			var main_game = get_tree().current_scene
			var mission_complete = main_game.get_node_or_null("MissionComplete")
			if mission_complete and mission_complete.has_method("show_mission_complete"):
				mission_complete.show_mission_complete()


