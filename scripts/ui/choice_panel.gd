# scripts/ui/choice_panel.gd
extends Control

@onready var question_label = $PanelContainer/VBoxContainer/QuestionLabel
@onready var options_container = $PanelContainer/VBoxContainer/OptionsContainer
@onready var feedback_label = $PanelContainer/VBoxContainer/FeedbackLabel

var choice_buttons: Array[Button] = []
var current_choice_id: String = ""
var _choice_data: Dictionary = {}

func _ready():
	hide()

func show_choice(choice_id: String):
	current_choice_id = choice_id
	GameManager.pause_game()
	var choices_data = load("res://dialogues/choices_data.gd").new()
	_choice_data = choices_data.get_choice(choice_id)

	question_label.text = _choice_data["question"]
	feedback_label.text = ""
	feedback_label.hide()

	for btn in choice_buttons:
		btn.queue_free()
	choice_buttons.clear()

	for idx in range(_choice_data["options"].size()):
		var option: Dictionary = _choice_data["options"][idx]
		var btn := Button.new()
		btn.text = option["text"]
		btn.custom_minimum_size = Vector2(0, 60)
		btn.pressed.connect(_on_choice_selected.bind(idx))
		options_container.add_child(btn)
		choice_buttons.append(btn)

	show()

func _on_choice_selected(option_index: int):
	var option: Dictionary = _choice_data["options"][option_index]
	var is_correct: bool = option.get("correct", false)
	GameManager.choice_made.emit(option_index, is_correct)

	# Delta de satisfação opcional (ex.: opção desrespeitosa derruba a satisfação).
	if option.has("satisfaction"):
		GameManager.add_satisfaction(option["satisfaction"])

	if is_correct:
		_show_feedback(option.get("feedback", "Resposta correta!"), true)
		for btn in choice_buttons:
			btn.disabled = true
		
		var continue_btn := Button.new()
		continue_btn.text = "Confirmar e Continuar"
		continue_btn.custom_minimum_size = Vector2(0, 60)
		continue_btn.pressed.connect(func():
			GameManager.advance_stage()
			GameManager.resume_game()
			hide()
			if current_choice_id == "choice_moradia_comprometida":
				DialogueManager.show_dialogue_balloon(
					load("res://dialogues/missao_01/dona_maria.dialogue"),
					"pos_quiz_moradia"
				)
		)
		options_container.add_child(continue_btn)
		choice_buttons.append(continue_btn)
	elif option.has("lesson"):
		# Opção com lição (ex.: lição de empatia): modal bloqueante com um botão
		# tipo "Pedir Desculpas" e o painel continua aberto para nova tentativa.
		await Popups.show_alert(option["lesson"], option.get("lesson_button", "Entendi"))
	else:
		_show_feedback(option.get("feedback", "Não é essa. Tente outra opção."), false)
		_flash_button(choice_buttons[option_index])

func _show_feedback(message: String, is_correct: bool) -> void:
	feedback_label.text = message
	feedback_label.show()
	if is_correct:
		feedback_label.add_theme_color_override("font_color", Color(0.15, 0.45, 0.25))
	else:
		feedback_label.add_theme_color_override("font_color", Color(0.65, 0.2, 0.2))

func _flash_button(btn: Button) -> void:
	var tween := create_tween()
	tween.tween_property(btn, "modulate", Color(1.0, 0.5, 0.5), 0.12)
	tween.tween_property(btn, "modulate", Color.WHITE, 0.25)
