extends Button

## Exported properties for customization
@export var hover_scale: float = 1.05
@export var animation_speed: float = 0.2
@export var color_normal: Color = Color.WHITE
@export var color_hover: Color = Color.YELLOW

## Internal state
var original_scale: Vector2
var original_color: Color
var tween: Tween = null


func _ready() -> void:
	# Store the original scale and color
	original_scale = scale
	original_color = modulate

	# Connect signals for hover and click
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)


func _on_mouse_entered() -> void:
	# Kill previous tween if it exists
	if tween:
		tween.kill()

	# Create a new tween for hover animation
	tween = _create_animation_tween()

	# Animate scale up and color change in parallel
	tween.tween_property(self, "scale", original_scale * hover_scale, animation_speed)
	tween.tween_property(self, "modulate", color_hover, animation_speed)


func _on_mouse_exited() -> void:
	# Kill previous tween if it exists
	if tween:
		tween.kill()

	# Create a new tween for exit animation
	tween = _create_animation_tween()

	# Animate scale back and color back in parallel
	tween.tween_property(self, "scale", original_scale, animation_speed)
	tween.tween_property(self, "modulate", original_color, animation_speed)


func _create_animation_tween() -> Tween:
	var t = create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUAD)
	t.set_parallel(true)
	return t


func _on_pressed() -> void:
	_play_click_sfx()


func _play_click_sfx() -> void:
	# Check if SFX file exists before attempting to load
	var sfx_path := "res://assets/sfx/button_click.ogg"
	if not ResourceLoader.exists(sfx_path):
		# No SFX file available, continue silently
		return

	# Create temporary AudioStreamPlayer for the click sound
	var sfx := AudioStreamPlayer.new()
	sfx.stream = load(sfx_path)
	sfx.bus = "Master"  # Use default Master bus
	add_child(sfx)

	# Play the sound and clean up after it finishes
	sfx.play()
	await sfx.finished
	sfx.queue_free()
