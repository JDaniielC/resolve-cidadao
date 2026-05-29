# scripts/ui/virtual_joystick.gd
extends Control

## Virtual Joystick for mobile/touch movement
## Emits input actions based on the stick's direction.

@onready var base = $Base
@onready var stick = $Base/Stick

@export var deadzone: float = 0.2
@export var max_distance: float = 50.0

var is_dragging: bool = false
var input_vector: Vector2 = Vector2.ZERO

func _ready():
	# Set translucent by default as per request
	modulate.a = 0.5
	# Center stick in base
	stick.position = (base.size / 2) - (stick.size / 2)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				_update_stick(event.position)
				_animate_modulate(0.8)
			else:
				is_dragging = false
				_reset_stick()
				_animate_modulate(0.5)

	elif event is InputEventMouseMotion and is_dragging:
		_update_stick(event.position)

func _update_stick(pos: Vector2):
	var center = base.size / 2
	var dir = (pos - center)
	var dist = dir.length()
	
	if dist > max_distance:
		dir = dir.normalized() * max_distance
	
	stick.position = center + dir - (stick.size / 2)
	
	# Calculate input vector for movement
	input_vector = dir / max_distance
	if input_vector.length() < deadzone:
		input_vector = Vector2.ZERO
	
	_handle_input_actions()

func _reset_stick():
	input_vector = Vector2.ZERO
	stick.position = (base.size / 2) - (stick.size / 2)
	_handle_input_actions()

func _handle_input_actions():
	# Map the vector to the game's actual move actions
	_set_action("move_right", input_vector.x > deadzone)
	_set_action("move_left", input_vector.x < -deadzone)
	_set_action("move_down", input_vector.y > deadzone)
	_set_action("move_up", input_vector.y < -deadzone)

func _set_action(action: String, pressed: bool):
	if pressed:
		if not Input.is_action_pressed(action):
			Input.action_press(action)
	else:
		if Input.is_action_pressed(action):
			Input.action_release(action)

func _animate_modulate(target_alpha: float):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", target_alpha, 0.2)
