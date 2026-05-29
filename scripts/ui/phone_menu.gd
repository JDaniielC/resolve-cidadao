# scripts/ui/phone_menu.gd
extends Control

@onready var close_button = $Panel/VBoxContainer/CloseButton
@onready var buttons_container = $Panel/VBoxContainer/ButtonsContainer

# Reference to individual buttons
@onready var problems_button = $Panel/VBoxContainer/ButtonsContainer/ProblemsButton
@onready var contacts_button = $Panel/VBoxContainer/ButtonsContainer/ContactsButton
@onready var satisfaction_button = $Panel/VBoxContainer/ButtonsContainer/SatisfactionButton
@onready var concepts_button = $Panel/VBoxContainer/ButtonsContainer/ConceptsButton

func _ready():
	hide()
	_setup_button_icons()
	
	# Connect buttons
	close_button.pressed.connect(_on_close_pressed)
	problems_button.pressed.connect(_on_problems_pressed)
	contacts_button.pressed.connect(_on_contacts_pressed)
	satisfaction_button.pressed.connect(_on_satisfaction_pressed)
	concepts_button.pressed.connect(_on_concepts_pressed)
	
	GameManager.stage_changed.connect(_on_stage_changed)

func _setup_button_icons():
	# Problems Button
	_add_icon_to_button(problems_button, "⚠️")
	# Contacts Button
	_add_icon_to_button(contacts_button, "📞")
	# Satisfaction Button
	_add_icon_to_button(satisfaction_button, "📊")
	# Concepts Button
	_add_icon_to_button(concepts_button, "📖")

func _add_icon_to_button(button: Button, icon_text: String):
	# Clear existing children if any (to avoid duplicates)
	for child in button.get_children():
		child.queue_free()
		
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 10)
	
	var icon_label = Label.new()
	icon_label.text = icon_text
	icon_label.add_theme_font_size_override("font_size", 20)
	
	var text_label = Label.new()
	text_label.text = button.text
	button.text = "" # Clear original text as we're using the label
	
	hbox.add_child(icon_label)
	hbox.add_child(text_label)
	button.add_child(hbox)

func _on_stage_changed(new_stage: int):
	if new_stage == 4:
		show()

func toggle():
	visible = not visible

func _on_close_pressed():
	hide()
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
