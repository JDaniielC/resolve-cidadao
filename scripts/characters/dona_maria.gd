# scripts/characters/dona_maria.gd
extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
var can_interact = false

func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)
	animated_sprite.play("Default")
	
	# Connect InteractionArea signals dynamically (both area and body to be bulletproof!)
	var interaction_area = $InteractionArea
	if interaction_area:
		interaction_area.body_entered.connect(func(body): _on_interaction_entered(body))
		interaction_area.body_exited.connect(func(body): _on_interaction_exited(body))
		interaction_area.area_entered.connect(func(area): _on_interaction_entered(area.get_parent()))
		interaction_area.area_exited.connect(func(area): _on_interaction_exited(area.get_parent()))
		print("Dona Maria: InteractionArea signals successfully connected in code.")
		
	# Initialize dialogue title matching current stage
	_update_dialogue_title()

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
	# Interaction and dialogue execution are fully handled by the StateMachine's
	# StateInteract and StateDialogue nodes in the scene. We dynamically update
	# the 'title' property on those nodes to match our stages.
	pass

func _update_dialogue_title():
	var dialogue_state = get_node_or_null("StateMachine/start_dialogue")
	if dialogue_state:
		if GameManager.current_stage == 2:
			dialogue_state.title = "intro"
		elif GameManager.current_stage in [3, 4, 5]:
			dialogue_state.title = "espera"
		elif GameManager.current_stage == 6:
			dialogue_state.title = "pos_resolucao"
		print("Dona Maria: Updated StateMachine dialogue state title to: ", dialogue_state.title)

func _on_dialogue_finished(_resource):
	if GameManager.current_stage == 2:
		print("Dona Maria: Initial dialogue finished, advancing stage...")
		GameManager.advance_stage()
		_update_dialogue_title()
	elif GameManager.current_stage == 6:
		print("Dona Maria: Post-resolution dialogue finished, advancing stage to end...")
		GameManager.advance_stage()
		_update_dialogue_title()
