# scripts/ui/choice_panel.gd
extends Control

@onready var question_label = $PanelContainer/VBoxContainer/QuestionLabel
@onready var options_container = $PanelContainer/VBoxContainer/OptionsContainer
var choice_buttons = []
var current_choice_id: String = ""

func _ready():
	hide()

func show_choice(choice_id: String):
	current_choice_id = choice_id
	var dialogue_data = load("res://dialogues/dona_maria_data.gd").new()
	var choice_data = dialogue_data.get_choice(choice_id)

	question_label.text = choice_data["question"]

	# Clear previous buttons
	for btn in choice_buttons:
		btn.queue_free()
	choice_buttons.clear()

	# Create buttons for each option
	for idx in range(choice_data["options"].size()):
		var option = choice_data["options"][idx]
		var btn = Button.new()
		btn.text = option["text"]
		btn.custom_minimum_size = Vector2(0, 60)
		btn.pressed.connect(_on_choice_selected.bindv([idx, option["correct"]]))
		options_container.add_child(btn)
		choice_buttons.append(btn)

	show()

func _on_choice_selected(option_index: int, is_correct: bool):
	GameManager.choice_made.emit(option_index, is_correct)
	if is_correct:
		print("Correct choice!")
		GameManager.advance_stage()
	else:
		print("Wrong choice, try again!")
	hide()
