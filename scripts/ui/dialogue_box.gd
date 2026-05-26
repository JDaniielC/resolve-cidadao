# scripts/ui/dialogue_box.gd
extends Control

@onready var character_label = $PanelContainer/VBoxContainer/CharacterLabel
@onready var text_label = $PanelContainer/VBoxContainer/TextLabel
@onready var continue_button = $PanelContainer/VBoxContainer/ContinueButton

func _ready():
	hide()
	continue_button.pressed.connect(_on_continue_pressed)
	DialogueSystem.dialogue_text_displayed.connect(_on_dialogue_text_displayed)
	DialogueSystem.dialogue_finished.connect(_on_dialogue_finished)
	DialogueSystem.show_choice_requested.connect(_on_show_choice_requested)

func _on_dialogue_text_displayed(character: String, text: String):
	character_label.text = character
	text_label.text = text
	show()

func _on_dialogue_finished(_dialogue_id: String):
	hide()

func _on_continue_pressed():
	DialogueSystem.show_next_text()

func _on_show_choice_requested(choice_id: String):
	hide()
	get_tree().root.get_node("MainGame/UILayer/ChoicePanel").show_choice(choice_id)
