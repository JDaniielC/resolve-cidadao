# scripts/characters/funcionario_abrigo.gd
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
		print("[FuncionarioAbrigo] InteractionArea signals connected.")
		
	_update_dialogue_title()
	GameManager.stage_changed.connect(func(_new_stage): _update_dialogue_title())

func _on_interaction_entered(node):
	if node and node.is_in_group("player"):
		can_interact = true
		node.set_npc_proximity(self)
		_update_dialogue_title()
		print("[FuncionarioAbrigo] Player entered interaction range. Stage: %d" % GameManager.current_stage)

func _on_interaction_exited(node):
	if node and node.is_in_group("player"):
		can_interact = false
		node.set_npc_proximity(null)
		print("[FuncionarioAbrigo] Player left interaction range.")

func is_player_near() -> bool:
	return can_interact

func trigger_dialogue():
	pass

func _update_dialogue_title():
	var dialogue_state = get_node_or_null("StateMachine/start_dialogue")
	if dialogue_state:
		if GameManager.current_stage >= 8:
			dialogue_state.title = "espera"
		else:
			dialogue_state.title = "intro"
		print("[FuncionarioAbrigo] Updated StateMachine dialogue title to: ", dialogue_state.title)

func _on_dialogue_finished(resource: DialogueResource):
	print("[FuncionarioAbrigo] Dialogue finished signal received. Resource path: %s, Current stage: %d" % [resource.resource_path if resource else "null", GameManager.current_stage])
	if resource and ("funcionario" in resource.resource_path or resource.resource_path.ends_with("funcionario.dialogue")):
		if GameManager.current_stage == 7:
			print("[FuncionarioAbrigo] Stage is 7. Advancing to stage 8...")
			GameManager.advance_stage()
			_update_dialogue_title()
