# scripts/systems/weather_controller.gd
# Reacts to GameManager.weather_changed and drives:
#   - CPUParticles2D  (rain intensity)
#   - AudioStreamPlayer (rain sound volume)
#   - A subtle extra color tint layered on top of DayNightController
extends Node

# --- References (auto-found in _ready, or assign via Inspector) ---
@export var rain_particles: CPUParticles2D
@export var rain_audio: AudioStreamPlayer

# Tween for smooth transitions
var _tween: Tween

# How long each weather transition takes (seconds)
const TRANSITION_DURATION: float = 6.0

# Per-weather profile: { amount, velocity_min, velocity_max, volume_db }
const WEATHER_PROFILES: Dictionary = {
	"Chuva Forte": {
		"amount": 300,
		"vel_min": 320.0,
		"vel_max": 420.0,
		"volume_db": 0.0,
	},
	"Chuva Leve": {
		"amount": 70,
		"vel_min": 180.0,
		"vel_max": 260.0,
		"volume_db": -14.0,
	},
	"Nublado": {
		"amount": 0,
		"vel_min": 0.0,
		"vel_max": 0.0,
		"volume_db": -80.0,
	},
	"Limpo": {
		"amount": 0,
		"vel_min": 0.0,
		"vel_max": 0.0,
		"volume_db": -80.0,
	},
	"Estiagem": {
		"amount": 0,
		"vel_min": 0.0,
		"vel_max": 0.0,
		"volume_db": -80.0,
	},
}

func _ready() -> void:
	# Auto-find siblings if not assigned in Inspector
	if not rain_particles:
		rain_particles = get_parent().get_node_or_null("CPUParticles2D")
	if not rain_audio:
		rain_audio = get_tree().root.find_child("AudioStreamPlayer", true, false)

	if not rain_particles:
		push_warning("WeatherController: CPUParticles2D not found.")
	if not rain_audio:
		push_warning("WeatherController: AudioStreamPlayer not found.")

	# Apply current weather immediately (no tween on startup)
	_apply_weather(GameManager.current_weather, false)

	# Listen for future changes
	GameManager.weather_changed.connect(_on_weather_changed)

func _on_weather_changed(new_weather: String) -> void:
	_apply_weather(new_weather, true)

func _apply_weather(weather: String, animated: bool) -> void:
	if not WEATHER_PROFILES.has(weather):
		push_warning("WeatherController: Unknown weather '%s'" % weather)
		return

	var profile: Dictionary = WEATHER_PROFILES[weather]

	if _tween:
		_tween.kill()

	if not animated:
		# Instant snap (used on game start)
		_set_particles_immediate(profile)
		if rain_audio:
			rain_audio.volume_db = profile["volume_db"]
		return

	# --- Animated transition ---
	_tween = create_tween()
	_tween.set_parallel(true)

	var target_amount: int = profile["amount"]
	var target_volume: float = profile["volume_db"]

	# 1. Audio fade
	if rain_audio:
		_tween.tween_property(rain_audio, "volume_db", target_volume, TRANSITION_DURATION).set_trans(Tween.TRANS_SINE)

	# 2. Particle amount: we can't tween 'amount' directly (it's int),
	#    so we use a callable tween to interpolate it smoothly.
	if rain_particles:
		var start_amount: int = rain_particles.amount
		_tween.tween_method(
			func(v: float): _set_particle_amount(int(v)),
			float(start_amount),
			float(target_amount),
			TRANSITION_DURATION
		).set_trans(Tween.TRANS_SINE)

		# 3. Velocity — tween min and max velocity
		_tween.tween_property(rain_particles, "initial_velocity_min", profile["vel_min"], TRANSITION_DURATION).set_trans(Tween.TRANS_SINE)
		_tween.tween_property(rain_particles, "initial_velocity_max", profile["vel_max"], TRANSITION_DURATION).set_trans(Tween.TRANS_SINE)

	# 4. Stop emitting fully once amount reaches 0
	if target_amount == 0:
		_tween.chain().tween_callback(func(): if rain_particles: rain_particles.emitting = false)
	else:
		if rain_particles:
			rain_particles.emitting = true

func _set_particles_immediate(profile: Dictionary) -> void:
	if not rain_particles:
		return
	rain_particles.amount = profile["amount"] if profile["amount"] else 0
	rain_particles.initial_velocity_min = profile["vel_min"]
	rain_particles.initial_velocity_max = profile["vel_max"]
	rain_particles.emitting = profile["amount"] > 0

func _set_particle_amount(value: int) -> void:
	if rain_particles:
		rain_particles.amount = max(1, value)
