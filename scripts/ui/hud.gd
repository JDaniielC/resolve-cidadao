# scripts/ui/hud.gd
extends CanvasLayer

@onready var stage_label = $TopLeftContainer/StagePanel/StageLabel
@onready var objective_label = $TopCenterContainer/ObjectivePanel/MarginContainer/ObjectiveLabel
@onready var cellphone_button = $CellphoneButton

var button_tween: Tween

func _ready():
	GameManager.stage_changed.connect(_on_stage_changed)
	
	# Basic button signal
	cellphone_button.pressed.connect(_on_cellphone_pressed)
	
	# Hover signals
	cellphone_button.mouse_entered.connect(_on_cellphone_hover.bind(true))
	cellphone_button.mouse_exited.connect(_on_cellphone_hover.bind(false))
	
	# Set pivot to center for scaling animation
	cellphone_button.pivot_offset = cellphone_button.size / 2
	
	_update_display()

func _update_display():
	stage_label.text = "Etapa %d/4" % GameManager.current_stage
	objective_label.text = GameManager.get_objective()

func _on_stage_changed(new_stage: int):
	_update_display()

## Open/close the phone menu.
func _on_cellphone_pressed():
	# Try to find PhoneMenu via the shared parent (MainGame)
	var main_game = get_parent()
	var phone = main_game.get_node_or_null("UILayer/PhoneMenu")
	
	# Fallback to root search if running the scene in isolation or from SceneManager
	if not phone:
		phone = get_tree().root.find_child("PhoneMenu", true, false)
	
	if phone:
		# Ensure the UILayer (CanvasLayer) is visible
		if phone.get_parent() is CanvasLayer:
			phone.get_parent().visible = true
		
		phone.toggle()
		print("[HUD] Cellphone button pressed. PhoneMenu visible: ", phone.visible)
	else:
		printerr("[HUD] Error: Could not find PhoneMenu in the scene tree.")

## Animate button on hover
func _on_cellphone_hover(is_hovering: bool):
	if button_tween:
		button_tween.kill()
	
	button_tween = create_tween()
	var target_scale = Vector2(1.15, 1.15) if is_hovering else Vector2(1.0, 1.0)
	var target_modulate = Color(1.2, 1.2, 1.2) if is_hovering else Color.WHITE
	
	button_tween.set_parallel(true)
	button_tween.tween_property(cellphone_button, "scale", target_scale, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	button_tween.tween_property(cellphone_button, "modulate", target_modulate, 0.15)
