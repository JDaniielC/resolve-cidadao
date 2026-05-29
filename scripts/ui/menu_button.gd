extends Button
## Menu button: adds a subtle hover scale-up and a click sound on top of the
## shared UI theme (assets/ui/theme.tres). Hover/pressed COLORS come from the
## theme's Button styles, so this script only handles motion + audio.

## Exported properties for customization
@export var hover_scale: float = 1.05
@export var animation_speed: float = 0.2

## Internal state
var original_scale: Vector2
var tween: Tween = null


func _ready() -> void:
	# Store the original scale and pivot on the center so the scale looks even.
	original_scale = scale
	pivot_offset = size / 2.0
	resized.connect(func() -> void: pivot_offset = size / 2.0)

	# Connect signals for hover and click
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)


func _on_mouse_entered() -> void:
	if tween:
		tween.kill()
	tween = _create_animation_tween()
	tween.tween_property(self, "scale", original_scale * hover_scale, animation_speed)


func _on_mouse_exited() -> void:
	if tween:
		tween.kill()
	tween = _create_animation_tween()
	tween.tween_property(self, "scale", original_scale, animation_speed)


func _create_animation_tween() -> Tween:
	var t = create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUAD)
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
