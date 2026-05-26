# scripts/ui/phone_menu.gd
extends Control

@onready var close_button = $Panel/VBoxContainer/CloseButton

func _ready():
	hide()
	close_button.pressed.connect(_on_close_pressed)
	GameManager.stage_changed.connect(_on_stage_changed)

func _on_stage_changed(new_stage: int):
	if new_stage == 4:
		show()

func _on_close_pressed():
	hide()
	GameManager.advance_stage()
