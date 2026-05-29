@tool
extends Control
class_name NPCGeneratorPanel

var npc_name_input: LineEdit
var sprite_path_label: Label
var sprite_path: String = ""
var sprite_button: Button

var dialogue_path_label: Label
var dialogue_path: String = ""
var dialogue_button: Button

var generate_button: Button
var clear_button: Button
var status_label: Label

var sprite_file_dialog: FileDialog
var dialogue_file_dialog: FileDialog

func _ready():
	# Create UI
	var vbox = VBoxContainer.new()
	add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "🎮 NPC Generator"
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	# Name input
	var name_label = Label.new()
	name_label.text = "Name:"
	vbox.add_child(name_label)

	npc_name_input = LineEdit.new()
	npc_name_input.placeholder_text = "e.g., Dona Maria"
	vbox.add_child(npc_name_input)

	vbox.add_child(Control.new())  # Spacer

	# Sprite selector
	var sprite_label = Label.new()
	sprite_label.text = "Sprite:"
	vbox.add_child(sprite_label)

	sprite_button = Button.new()
	sprite_button.text = "Select PNG..."
	sprite_button.pressed.connect(_on_sprite_button_pressed)
	vbox.add_child(sprite_button)

	sprite_path_label = Label.new()
	sprite_path_label.text = "[No sprite selected]"
	sprite_path_label.add_theme_color_override("font_color", Color.GRAY)
	vbox.add_child(sprite_path_label)

	vbox.add_child(Control.new())  # Spacer

	# Dialogue selector
	var dialogue_label = Label.new()
	dialogue_label.text = "Dialogue:"
	vbox.add_child(dialogue_label)

	dialogue_button = Button.new()
	dialogue_button.text = "Select .dialogue..."
	dialogue_button.pressed.connect(_on_dialogue_button_pressed)
	vbox.add_child(dialogue_button)

	dialogue_path_label = Label.new()
	dialogue_path_label.text = "[No dialogue selected]"
	dialogue_path_label.add_theme_color_override("font_color", Color.GRAY)
	vbox.add_child(dialogue_path_label)

	vbox.add_child(Control.new())  # Spacer

	# Buttons
	var button_hbox = HBoxContainer.new()
	vbox.add_child(button_hbox)

	generate_button = Button.new()
	generate_button.text = "Generate NPC"
	generate_button.pressed.connect(_on_generate_pressed)
	button_hbox.add_child(generate_button)

	clear_button = Button.new()
	clear_button.text = "Clear"
	clear_button.pressed.connect(_on_clear_pressed)
	button_hbox.add_child(clear_button)

	# Status label
	vbox.add_child(HSeparator.new())
	status_label = Label.new()
	status_label.text = "Ready"
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(status_label)

	# File dialogs
	sprite_file_dialog = FileDialog.new()
	sprite_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	sprite_file_dialog.filters = PackedStringArray(["*.png ; PNG Images", "*.jpg ; JPEG Images"])
	# FILE_MODE_OPEN_FILE emits file_selected(path), NOT files_selected(paths)
	# (the latter only fires in FILE_MODE_OPEN_FILES).
	sprite_file_dialog.file_selected.connect(_on_sprite_file_selected)
	add_child(sprite_file_dialog)

	dialogue_file_dialog = FileDialog.new()
	dialogue_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialogue_file_dialog.filters = PackedStringArray(["*.dialogue ; Dialogue Files"])
	dialogue_file_dialog.file_selected.connect(_on_dialogue_file_selected)
	add_child(dialogue_file_dialog)

	# Styling
	custom_minimum_size = Vector2(400, 0)

func _on_sprite_button_pressed():
	sprite_file_dialog.popup_centered_ratio(0.7)

func _on_sprite_file_selected(path: String):
	sprite_path = path
	sprite_path_label.text = sprite_path

func _on_dialogue_button_pressed():
	dialogue_file_dialog.popup_centered_ratio(0.7)

func _on_dialogue_file_selected(path: String):
	dialogue_path = path
	dialogue_path_label.text = dialogue_path

func _on_generate_pressed():
	var name = npc_name_input.text.strip_edges()

	if name.is_empty():
		_show_error("Name is required")
		return

	if sprite_path.is_empty():
		_show_error("Sprite is required")
		return

	if dialogue_path.is_empty():
		_show_error("Dialogue is required")
		return

	generate_button.disabled = true
	status_label.text = "Generating..."

	var generator = NPCGenerator.new()
	var result = generator.generate(name, sprite_path, dialogue_path)

	if result.is_error():
		_show_error(result.get_error())
		generate_button.disabled = false
		return

	var data = result.get_value()
	status_label.text = "✅ NPC created: %s" % data.name
	status_label.add_theme_color_override("font_color", Color.GREEN)

	# Open in editor (EditorInterface is accessed statically in Godot 4.2+)
	EditorInterface.open_scene_from_path(data.path)

	generate_button.disabled = false
	await get_tree().create_timer(2.0).timeout
	_on_clear_pressed()

func _on_clear_pressed():
	npc_name_input.text = ""
	sprite_path = ""
	dialogue_path = ""
	sprite_path_label.text = "[No sprite selected]"
	dialogue_path_label.text = "[No dialogue selected]"
	status_label.text = "Ready"
	status_label.remove_theme_color_override("font_color")

func _show_error(message: String):
	status_label.text = "❌ Error: " + message
	status_label.add_theme_color_override("font_color", Color.RED)
