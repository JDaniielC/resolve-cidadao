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
	
	_update_display()
	last_objective = GameManager.get_objective()

func _update_display():
	#stage_label.text = "Etapa %d/4" % GameManager.current_stage
	
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
		await get_tree().create_timer(0.2).timeout # Mid-point of animation
		objective_label.text = new_text
		last_objective = new_text
	else:
		objective_label.text = new_text
		last_objective = new_text

func _on_stage_changed(new_stage: int):
	_update_display()
	# Stage 3 = player needs to open the phone → start glowing
	if new_stage == 3:
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

## Open/close the phone menu.
func _on_cellphone_pressed():
	# Stop glow when player opens the phone
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
		return  # Don't override glow animation on hover
	if button_tween:
		button_tween.kill()
	button_tween = create_tween()
	var target_scale = Vector2(1.15, 1.15) if is_hovering else Vector2(1.0, 1.0)
	var target_modulate = Color(1.2, 1.2, 1.2) if is_hovering else Color.WHITE
	button_tween.set_parallel(true)
	button_tween.tween_property(cellphone_button, "scale", target_scale, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	button_tween.tween_property(cellphone_button, "modulate", target_modulate, 0.15)

## Starts a looping pulse animation on the cellphone button to attract attention.
func _start_phone_glow():
	if _phone_glowing:
		return
	_phone_glowing = true
	cellphone_button.pivot_offset = cellphone_button.size / 2
	
	if glow_tween:
		glow_tween.kill()
	glow_tween = create_tween().set_loops()
	glow_tween.set_parallel(true)
	# Scale pulse: 1.0 → 1.25 → 1.0
	glow_tween.tween_property(cellphone_button, "scale", Vector2(1.25, 1.25), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	glow_tween.chain().tween_property(cellphone_button, "scale", Vector2(1.0, 1.0), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# Color pulse: white → bright yellow → white
	glow_tween.tween_property(cellphone_button, "modulate", Color(1.5, 1.4, 0.3, 1.0), 0.55).set_trans(Tween.TRANS_SINE)
	glow_tween.chain().tween_property(cellphone_button, "modulate", Color.WHITE, 0.55).set_trans(Tween.TRANS_SINE)

## Stops the glow animation and resets the button to its normal state.
func _stop_phone_glow():
	if not _phone_glowing:
		return
	_phone_glowing = false
	if glow_tween:
		glow_tween.kill()
		glow_tween = null
	cellphone_button.scale = Vector2.ONE
	cellphone_button.modulate = Color.WHITE
