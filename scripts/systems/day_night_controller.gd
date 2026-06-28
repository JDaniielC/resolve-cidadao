# scripts/systems/day_night_controller.gd
# Drives the CanvasModulate color based on GameManager.game_hour
# to create a smooth day/night lighting cycle.
extends Node

## The CanvasModulate node to tint. Assign in the Inspector or via script.
@export var canvas_modulate: CanvasModulate
## Limite inferior de brilho — evita noite ilegível sem apagar o escuro.
@export var min_brightness: float = 0.38

# Color keyframes for each part of the day (hour → Color)
const DAY_PALETTE: Array = [
	# [hour, Color]
	[0,  Color(0.12, 0.13, 0.22)],  # Midnight
	[5,  Color(0.16, 0.15, 0.26)],  # Pre-dawn
	[6,  Color(0.55, 0.35, 0.30)],  # Sunrise
	[7,  Color(0.80, 0.70, 0.60)],  # Early morning
	[8,  Color(0.72, 0.84, 0.95)],  # Morning
	[12, Color(1.00, 0.98, 0.92)],  # Noon
	[16, Color(0.95, 0.85, 0.70)],  # Afternoon
	[18, Color(0.80, 0.50, 0.30)],  # Sunset
	[19, Color(0.40, 0.32, 0.38)],  # Dusk
	[20, Color(0.22, 0.20, 0.30)],  # Evening
	[22, Color(0.15, 0.16, 0.24)],  # Night
	[24, Color(0.12, 0.13, 0.22)],  # Wraps to midnight
]

var _tween: Tween

func _ready() -> void:
	if not canvas_modulate:
		canvas_modulate = get_parent().get_node_or_null("%CanvasModulate")
		if not canvas_modulate:
			# Try unique name lookup first, then by name
			canvas_modulate = get_tree().root.find_child("CanvasModulate", true, false)
	
	if not canvas_modulate:
		push_warning("DayNightController: No CanvasModulate found. Lighting won't update.")
		return
	
	# Set starting color for the current hour (no tween, instant snap)
	canvas_modulate.color = _get_color_for_hour(GameManager.game_hour, GameManager.game_minute)
	
	# Listen for future time changes
	GameManager.time_changed.connect(_on_time_changed)

func _on_time_changed(hour: int, minute: int) -> void:
	if not canvas_modulate:
		return
	
	var target_color: Color = _get_color_for_hour(hour, minute)
	
	# Smoothly interpolate to the target color over 1 second
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(canvas_modulate, "color", target_color, 1.0).set_trans(Tween.TRANS_SINE)

func _get_color_for_hour(hour: int, minute: int) -> Color:
	var time_decimal: float = hour + (minute / 60.0)
	
	# Find the two surrounding keyframes
	var prev_kf: Array = DAY_PALETTE[0]
	var next_kf: Array = DAY_PALETTE[DAY_PALETTE.size() - 1]
	
	for i in range(DAY_PALETTE.size() - 1):
		var kf_a: Array = DAY_PALETTE[i]
		var kf_b: Array = DAY_PALETTE[i + 1]
		if time_decimal >= kf_a[0] and time_decimal < kf_b[0]:
			prev_kf = kf_a
			next_kf = kf_b
			break
	
	# Lerp between the two keyframes
	var span: float = next_kf[0] - prev_kf[0]
	if span == 0.0:
		return prev_kf[1]
	
	var t: float = (time_decimal - prev_kf[0]) / span
	var color: Color = prev_kf[1].lerp(next_kf[1], t)
	return _clamp_brightness(color)

func _clamp_brightness(color: Color) -> Color:
	return Color(
		maxf(color.r, min_brightness),
		maxf(color.g, min_brightness),
		maxf(color.b, min_brightness),
		color.a
	)
