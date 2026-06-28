extends CPUParticles2D
## Chuva que segue a câmera no mundo — cobre a tela visível com qualquer zoom.

const PROFILE := {
	"Chuva Forte": {"amount": 220, "vel_min": 280.0, "vel_max": 380.0, "emitting": true},
	"Chuva Leve": {"amount": 90, "vel_min": 200.0, "vel_max": 280.0, "emitting": true},
	"Nublado": {"amount": 0, "vel_min": 0.0, "vel_max": 0.0, "emitting": false},
	"Limpo": {"amount": 0, "vel_min": 0.0, "vel_max": 0.0, "emitting": false},
	"Estiagem": {"amount": 0, "vel_min": 0.0, "vel_max": 0.0, "emitting": false},
}

var _suppressed := false

func _ready() -> void:
	add_to_group("rain_particles")
	z_index = 100
	modulate = Color(1, 1, 1, 0.72)
	_build_streak_texture()
	_setup_emission()
	GameManager.weather_changed.connect(_apply_weather)
	await get_tree().process_frame
	_follow_camera()
	_apply_weather(GameManager.current_weather)

func _physics_process(_delta: float) -> void:
	_follow_camera()

func _build_streak_texture() -> void:
	var img := Image.create(1, 18, false, Image.FORMAT_RGBA8)
	for y in range(18):
		var alpha := lerpf(0.7, 0.12, float(y) / 17.0)
		img.set_pixel(0, y, Color(0.8, 0.9, 1.0, alpha))
	texture = ImageTexture.create_from_image(img)

func _setup_emission() -> void:
	lifetime = 1.6
	explosiveness = 0.0
	direction = Vector2(0.15, 1.0)
	spread = 5.0
	gravity = Vector2.ZERO
	scale_amount_min = 0.55
	scale_amount_max = 0.85
	emission_shape = EMISSION_SHAPE_RECTANGLE

func _get_camera() -> Camera2D:
	return get_viewport().get_camera_2d()

func _follow_camera() -> void:
	var camera := _get_camera()
	if not camera:
		return

	var zoom := camera.zoom
	var vp_size := get_viewport_rect().size
	var half_w := vp_size.x * 0.5 / zoom.x + 80.0
	var top_offset := vp_size.y * 0.5 / zoom.y + 24.0

	global_position = camera.global_position + Vector2(0.0, -top_offset)
	emission_rect_extents = Vector2(half_w, 12.0)

func set_suppressed(value: bool) -> void:
	_suppressed = value
	_apply_weather(GameManager.current_weather)

func _apply_weather(weather: String) -> void:
	if _suppressed:
		emitting = false
		return
	var profile: Dictionary = PROFILE.get(weather, PROFILE["Nublado"])
	amount = profile["amount"]
	initial_velocity_min = profile["vel_min"]
	initial_velocity_max = profile["vel_max"]
	var should_emit: bool = profile["emitting"]
	if emitting != should_emit:
		emitting = should_emit
	elif should_emit:
		restart()
