# scenes/props/radio_item.gd
extends Node2D

var _collected := false
var _player_nearby := false

func _ready():
	_update_visibility()
	GameManager.stage_changed.connect(func(_s): _update_visibility())

	for child in get_children():
		if child is Area2D:
			child.body_entered.connect(_on_body_entered)
			child.body_exited.connect(_on_body_exited)
			break

	_set_prompt(false)

func _update_visibility():
	# Aparece só no stage 15, quando Severino pediu o rádio
	visible = GameManager.current_stage == 15 and not _collected

func _on_body_entered(body):
	if body.is_in_group("player") and not _collected:
		_player_nearby = true
		_set_prompt(true)

func _on_body_exited(body):
	if body.is_in_group("player"):
		_player_nearby = false
		_set_prompt(false)

func _set_prompt(value: bool):
	var prompt = get_node_or_null("InteractionPrompt")
	if not prompt:
		prompt = get_node_or_null("Label")
	if prompt:
		prompt.visible = value

func _input(event):
	if _collected or not _player_nearby:
		return
	if event.is_action_pressed("interact"):
		_collect()

func _collect():
	_collected = true
	_set_prompt(false)
	visible = false

	Notifications.notify_sms(
		"Rádio de Pilha",
		"Você pegou o rádio. Agora volte falar com Seu Severino."
	)

	GameManager.radio_collected = true
	GameManager.advance_stage()  # 15 → 16 (conversa final com Severino)
