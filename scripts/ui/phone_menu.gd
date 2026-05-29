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

## Toggle the phone open/closed. Called by the HUD's CELULAR button.
## NOTE: pressing the in-phone "Fechar" button still advances the tutorial stage
## (see _on_close_pressed). Revisit the full open/close interaction when the
## stage-gating logic for the cellphone is finalized.
func toggle():
	visible = not visible

func _on_close_pressed():
	hide()
	GameManager.advance_stage()
