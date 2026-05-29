# scripts/ui/phone_menu.gd
extends Control

@onready var close_button = $Panel/VBoxContainer/CloseButton
@onready var problems_button = $Panel/VBoxContainer/ButtonsContainer/ProblemsButton
@onready var contacts_button = $Panel/VBoxContainer/ButtonsContainer/ContactsButton
@onready var satisfaction_button = $Panel/VBoxContainer/ButtonsContainer/SatisfactionButton
@onready var concepts_button = $Panel/VBoxContainer/ButtonsContainer/ConceptsButton

func _ready():
	hide()
	# Connect buttons
	close_button.pressed.connect(_on_close_pressed)
	problems_button.pressed.connect(_on_problems_pressed)
	contacts_button.pressed.connect(_on_contacts_pressed)
	satisfaction_button.pressed.connect(_on_satisfaction_pressed)
	concepts_button.pressed.connect(_on_concepts_pressed)
	
	GameManager.stage_changed.connect(_on_stage_changed)

func _on_stage_changed(new_stage: int):
	# Tutorial logic: auto-show phone on stage 4
	if new_stage == 4:
		show()

## Toggle the phone open/closed. Called by the HUD's CELULAR button.
func toggle():
	visible = not visible
	if visible:
		# Could play an animation here in the future
		print("[PhoneMenu] Menu opened")

func _on_close_pressed():
	hide()
	# If we are in the tutorial stage for the phone, advance it
	if GameManager.current_stage == 4:
		GameManager.advance_stage()

func _on_problems_pressed():
	print("[PhoneMenu] Registro de Problemas selected (TODO)")

func _on_contacts_pressed():
	print("[PhoneMenu] Contatos Úteis selected (TODO)")

func _on_satisfaction_pressed():
	print("[PhoneMenu] Satisfação da Cidade selected (TODO)")

func _on_concepts_pressed():
	print("[PhoneMenu] Base de Conhecimento selected (TODO)")
