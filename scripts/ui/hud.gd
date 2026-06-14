# scripts/ui/hud.gd
extends CanvasLayer

@onready var time_label = $TopLeftContainer/VBox/TimeWeatherPanel/Margin/HBox/TimeLabel
@onready var weather_icon = $TopLeftContainer/VBox/TimeWeatherPanel/Margin/HBox/WeatherIcon
@onready var weather_label = $TopLeftContainer/VBox/TimeWeatherPanel/Margin/HBox/WeatherLabel

@onready var objective_label = $TopLeftContainer/VBox/ObjectivePanel/Margin/ObjectiveLabel
@onready var anim_player = $AnimationPlayer

@onready var satisfaction_bar = $TopRightContainer/VBox/SatisfactionPanel/Margin/HBox/VBox/SatisfactionBar
@onready var percentage_label = $TopRightContainer/VBox/SatisfactionPanel/Margin/HBox/PercentageLabel
@onready var cellphone_button = $TopRightContainer/VBox/Control/CellphoneButton

var button_tween: Tween
var glow_tween: Tween
var last_objective: String = ""
var _phone_glowing: bool = false

# Mobile interaction button & Tutorial overlay variables
var interact_button: Button
var bottom_right_container: MarginContainer

var tutorial_overlay: ColorRect
var tutorial_panel: PanelContainer
var tutorial_title: Label
var tutorial_desc: Label
var tutorial_button: Button
var tutorial_index: int = 0
var is_tutorial_active: bool = false
var tutorial_pulse_tween: Tween

const HUD_TUTORIAL := [
	{
		"title": "🎮 Movimentação",
		"text": "Use o joystick virtual no canto inferior esquerdo para se movimentar pelo Coque.",
		"target": "joystick"
	},
	{
		"title": "🤝 Interação",
		"text": "Quando estiver perto de um morador ou ponto de interesse, toque no botão E no canto inferior direito para iniciar o diálogo.",
		"target": "interact"
	},
	{
		"title": "📊 Barra de Satisfação",
		"text": "Esta barra mostra a satisfação da comunidade. Resolver queixas do bairro aumenta o índice, enquanto ignorar problemas a diminui.",
		"target": "satisfaction"
	}
]

func _ready():
	# Connect signals
	GameManager.stage_changed.connect(_on_stage_changed)
	GameManager.satisfaction_changed.connect(_on_satisfaction_changed)
	GameManager.time_changed.connect(_on_time_changed)
	GameManager.weather_changed.connect(_on_weather_changed)
	
	cellphone_button.pressed.connect(_on_cellphone_pressed)
	cellphone_button.mouse_entered.connect(_on_cellphone_hover.bind(true))
	cellphone_button.mouse_exited.connect(_on_cellphone_hover.bind(false))
	
	cellphone_button.pivot_offset = cellphone_button.size / 2
	
	# Build mobile interact button and tutorial structures
	_build_interact_button()
	_build_tutorial_ui()
	
	_update_display()
	last_objective = GameManager.get_objective()

func _build_interact_button() -> void:
	bottom_right_container = MarginContainer.new()
	bottom_right_container.name = "BottomRightContainer"
	bottom_right_container.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	bottom_right_container.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	bottom_right_container.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bottom_right_container.add_theme_constant_override("margin_right", 40)
	bottom_right_container.add_theme_constant_override("margin_bottom", 40)
	add_child(bottom_right_container)
	
	interact_button = Button.new()
	interact_button.name = "InteractButton"
	interact_button.text = "E"
	interact_button.custom_minimum_size = Vector2(80, 80)
	
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.2, 0.2, 0.2, 0.5) # Translucent gray
	style_normal.border_width_left = 2
	style_normal.border_width_top = 2
	style_normal.border_width_right = 2
	style_normal.border_width_bottom = 2
	style_normal.border_color = Color(0.8, 0.8, 0.8, 0.4) # Subtle gray/white border
	style_normal.corner_radius_top_left = 40
	style_normal.corner_radius_top_right = 40
	style_normal.corner_radius_bottom_right = 40
	style_normal.corner_radius_bottom_left = 40
	style_normal.shadow_color = Color(0, 0, 0, 0.2)
	style_normal.shadow_size = 4
	
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color(0.3, 0.3, 0.3, 0.6)
	
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = Color(0.1, 0.1, 0.1, 0.7)
	
	interact_button.add_theme_stylebox_override("normal", style_normal)
	interact_button.add_theme_stylebox_override("hover", style_hover)
	interact_button.add_theme_stylebox_override("pressed", style_pressed)
	interact_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	interact_button.add_theme_font_size_override("font_size", 28)
	interact_button.add_theme_color_override("font_color", Color.WHITE)
	
	interact_button.pressed.connect(_on_interact_pressed)
	bottom_right_container.add_child(interact_button)

func _build_tutorial_ui() -> void:
	tutorial_overlay = ColorRect.new()
	tutorial_overlay.name = "TutorialOverlay"
	tutorial_overlay.color = Color(0, 0, 0, 0.65) # Dark tint over the screen
	tutorial_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	tutorial_overlay.hide()
	add_child(tutorial_overlay)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_overlay.add_child(center)
	
	tutorial_panel = PanelContainer.new()
	tutorial_panel.custom_minimum_size = Vector2(480, 0)
	center.add_child(tutorial_panel)
	
	var style_panel = StyleBoxFlat.new()
	style_panel.bg_color = Color("1A2421") # Dark green-gray
	style_panel.border_width_left = 3
	style_panel.border_width_top = 3
	style_panel.border_width_right = 3
	style_panel.border_width_bottom = 3
	style_panel.border_color = Color("2E6B8A") # City blue accent
	style_panel.corner_radius_top_left = 12
	style_panel.corner_radius_top_right = 12
	style_panel.corner_radius_bottom_right = 12
	style_panel.corner_radius_bottom_left = 12
	style_panel.shadow_color = Color(0, 0, 0, 0.4)
	style_panel.shadow_size = 10
	tutorial_panel.add_theme_stylebox_override("panel", style_panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	tutorial_panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)
	
	tutorial_title = Label.new()
	tutorial_title.add_theme_font_size_override("font_size", 20)
	tutorial_title.add_theme_color_override("font_color", Color("E07A5F"))
	tutorial_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(tutorial_title)
	
	tutorial_desc = Label.new()
	tutorial_desc.add_theme_font_size_override("font_size", 15)
	tutorial_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(tutorial_desc)
	
	tutorial_button = Button.new()
	tutorial_button.text = "Próximo"
	tutorial_button.custom_minimum_size = Vector2(120, 40)
	tutorial_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	var style_btn_normal = StyleBoxFlat.new()
	style_btn_normal.bg_color = Color("2E6B8A")
	style_btn_normal.corner_radius_top_left = 6
	style_btn_normal.corner_radius_top_right = 6
	style_btn_normal.corner_radius_bottom_right = 6
	style_btn_normal.corner_radius_bottom_left = 6
	
	var style_btn_hover = style_btn_normal.duplicate()
	style_btn_hover.bg_color = Color("3D85A8")
	
	var style_btn_pressed = style_btn_normal.duplicate()
	style_btn_pressed.bg_color = Color("22536B")
	
	tutorial_button.add_theme_stylebox_override("normal", style_btn_normal)
	tutorial_button.add_theme_stylebox_override("hover", style_btn_hover)
	tutorial_button.add_theme_stylebox_override("pressed", style_btn_pressed)
	tutorial_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	tutorial_button.add_theme_color_override("font_color", Color.WHITE)
	
	tutorial_button.pressed.connect(_on_tutorial_next_pressed)
	vbox.add_child(tutorial_button)

func start_tutorial() -> void:
	is_tutorial_active = true
	tutorial_index = 0
	GameManager.pause_game()
	tutorial_overlay.show()
	_update_tutorial_step()

func _update_tutorial_step() -> void:
	var step = HUD_TUTORIAL[tutorial_index]
	tutorial_title.text = step["title"]
	tutorial_desc.text = step["text"]
	tutorial_button.text = "Entendi" if tutorial_index >= HUD_TUTORIAL.size() - 1 else "Próximo"
	_highlight_element(step["target"])

func _on_tutorial_next_pressed() -> void:
	if tutorial_index < HUD_TUTORIAL.size() - 1:
		tutorial_index += 1
		_update_tutorial_step()
	else:
		_end_tutorial()

func _highlight_element(target: String) -> void:
	if tutorial_pulse_tween:
		tutorial_pulse_tween.kill()
	
	# Dim all main HUD elements
	$TopLeftContainer.modulate = Color(0.35, 0.35, 0.35)
	$TopRightContainer/VBox/SatisfactionPanel.modulate = Color(0.35, 0.35, 0.35)
	$TopRightContainer/VBox/Control/CellphoneButton.modulate = Color(0.35, 0.35, 0.35)
	$BottomLeftContainer/VirtualJoystick.modulate = Color(0.35, 0.35, 0.35)
	if is_instance_valid(interact_button):
		interact_button.modulate = Color(0.35, 0.35, 0.35)
	
	var target_node: Control = null
	if target == "joystick":
		target_node = $BottomLeftContainer/VirtualJoystick
	elif target == "interact":
		target_node = interact_button
	elif target == "satisfaction":
		target_node = $TopRightContainer/VBox/SatisfactionPanel
		
	if target_node:
		target_node.modulate = Color.WHITE
		tutorial_pulse_tween = create_tween().set_loops()
		tutorial_pulse_tween.tween_property(target_node, "modulate", Color(1.6, 1.6, 1.6), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tutorial_pulse_tween.tween_property(target_node, "modulate", Color.WHITE, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _end_tutorial() -> void:
	is_tutorial_active = false
	if tutorial_pulse_tween:
		tutorial_pulse_tween.kill()
		
	# Restore normal modulations
	$TopLeftContainer.modulate = Color.WHITE
	$TopRightContainer/VBox/SatisfactionPanel.modulate = Color.WHITE
	$TopRightContainer/VBox/Control/CellphoneButton.modulate = Color.WHITE
	$BottomLeftContainer/VirtualJoystick.modulate = Color(1.0, 1.0, 1.0, 0.5) # Translucent joystick
	if is_instance_valid(interact_button):
		interact_button.modulate = Color.WHITE
		
	tutorial_overlay.hide()
	
	# Resume game and enable player controls
	GameManager.resume_game()
	for player in Globals.get_players():
		if player is PlayerEntity:
			player.input_enabled = true

func _on_interact_pressed() -> void:
	if is_tutorial_active:
		return
	var ev_press = InputEventAction.new()
	ev_press.action = "interact"
	ev_press.pressed = true
	Input.parse_input_event(ev_press)
	
	await get_tree().process_frame
	
	var ev_release = InputEventAction.new()
	ev_release.action = "interact"
	ev_release.pressed = false
	Input.parse_input_event(ev_release)


func _update_display():
	var new_objective = GameManager.get_objective()
	if new_objective != last_objective:
		_animate_objective_change(new_objective)
	else:
		objective_label.text = new_objective
		
	_update_satisfaction_ui(GameManager.satisfaction)
	_update_time_ui(GameManager.game_hour, GameManager.game_minute)
	_update_weather_ui(GameManager.current_weather)

func _animate_objective_change(new_text: String):
	if anim_player and anim_player.has_animation("objective_update"):
		anim_player.play("objective_update")
		await get_tree().create_timer(0.2).timeout
		objective_label.text = new_text
		last_objective = new_text
	else:
		objective_label.text = new_text
		last_objective = new_text

func _on_stage_changed(new_stage: int):
	_update_display()
	if new_stage == 4:
		_start_phone_glow()

func _on_satisfaction_changed(new_value: float):
	var tween = create_tween()
	tween.tween_property(satisfaction_bar, "value", new_value, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	percentage_label.text = "%d%%" % int(new_value)

func _on_time_changed(hour: int, minute: int):
	_update_time_ui(hour, minute)

func _on_weather_changed(new_weather: String):
	_update_weather_ui(new_weather)

func _update_satisfaction_ui(value: float):
	satisfaction_bar.value = value
	percentage_label.text = "%d%%" % int(value)

func _update_time_ui(hour: int, minute: int):
	time_label.text = "%02d:%02d" % [hour, minute]

func _update_weather_ui(weather: String):
	weather_label.text = weather
	match weather:
		"Chuva Forte", "Enchente":
			weather_icon.text = "⛈️"
		"Chuva Leve":
			weather_icon.text = "🌧️"
		"Nublado":
			weather_icon.text = "☁️"
		"Estiagem", "Limpo":
			weather_icon.text = "☀️"
		_:
			weather_icon.text = "🌤️"

func _on_cellphone_pressed():
	if GameManager.current_stage < 4:
		return

	_stop_phone_glow()
	
	var main_game = get_parent()
	var phone = main_game.get_node_or_null("UILayer/PhoneMenu")
	if not phone:
		phone = get_tree().root.find_child("PhoneMenu", true, false)
	
	if phone:
		if phone.get_parent() is CanvasLayer:
			phone.get_parent().visible = true
		phone.toggle()

func _on_cellphone_hover(is_hovering: bool):
	if _phone_glowing:
		return
	if button_tween:
		button_tween.kill()
	button_tween = create_tween()
	var target_scale = Vector2(1.15, 1.15) if is_hovering else Vector2(1.0, 1.0)
	var target_modulate = Color(1.2, 1.2, 1.2) if is_hovering else Color.WHITE
	button_tween.set_parallel(true)
	button_tween.tween_property(cellphone_button, "scale", target_scale, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	button_tween.tween_property(cellphone_button, "modulate", target_modulate, 0.15)

func _start_phone_glow():
	if _phone_glowing:
		return
	_phone_glowing = true
	cellphone_button.pivot_offset = cellphone_button.size / 2
	
	if glow_tween:
		glow_tween.kill()
	glow_tween = create_tween().set_loops()
	glow_tween.set_parallel(true)
	glow_tween.tween_property(cellphone_button, "scale", Vector2(1.25, 1.25), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	glow_tween.chain().tween_property(cellphone_button, "scale", Vector2(1.0, 1.0), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	glow_tween.tween_property(cellphone_button, "modulate", Color(1.5, 1.4, 0.3, 1.0), 0.55).set_trans(Tween.TRANS_SINE)
	glow_tween.chain().tween_property(cellphone_button, "modulate", Color.WHITE, 0.55).set_trans(Tween.TRANS_SINE)

func _stop_phone_glow():
	if not _phone_glowing:
		return
	_phone_glowing = false
	if glow_tween:
		glow_tween.kill()
		glow_tween = null
	cellphone_button.scale = Vector2.ONE
	cellphone_button.modulate = Color.WHITE
