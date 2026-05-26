# scripts/systems/dialogue_system.gd
extends Node

signal dialogue_started(dialogue_id: String)
signal dialogue_finished(dialogue_id: String)
signal dialogue_text_displayed(character: String, text: String)
signal show_choice_requested(choice_id: String)

var current_dialogue_id: String = ""
var current_dialogue_index: int = 0
var is_dialogue_active: bool = false

func start_dialogue(dialogue_id: String):
	current_dialogue_id = dialogue_id
	current_dialogue_index = 0
	is_dialogue_active = true
	dialogue_started.emit(dialogue_id)
	show_next_text()

func show_next_text():
	var dialogue_data = load("res://dialogues/dona_maria_data.gd").new()
	var dialogue = dialogue_data.get_dialogue(current_dialogue_id)

	if current_dialogue_index < dialogue.size():
		var text_data = dialogue[current_dialogue_index]
		dialogue_text_displayed.emit(text_data["character"], text_data["text"])
		current_dialogue_index += 1
	else:
		finish_dialogue()

func finish_dialogue():
	is_dialogue_active = false
	dialogue_finished.emit(current_dialogue_id)

	# Check if next is a choice
	if current_dialogue_id == "intro":
		show_choice_requested.emit("choice_housing")

	current_dialogue_id = ""

func is_active() -> bool:
	return is_dialogue_active
