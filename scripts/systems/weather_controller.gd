# scripts/systems/weather_controller.gd
# Reage a GameManager.weather_changed e controla o volume do áudio de chuva.
# As partículas ficam em ScreenRain (MainGame) — ver screen_rain.gd.
extends Node

@export var rain_audio: AudioStreamPlayer

var _tween: Tween

const TRANSITION_DURATION: float = 6.0

const VOLUME_DB := {
	"Chuva Forte": 0.0,
	"Chuva Leve": -14.0,
	"Nublado": -80.0,
	"Limpo": -80.0,
	"Estiagem": -80.0,
}

func _ready() -> void:
	if not rain_audio:
		rain_audio = get_tree().root.find_child("AudioStreamPlayer", true, false) as AudioStreamPlayer
	if not rain_audio:
		push_warning("WeatherController: AudioStreamPlayer not found.")

	_apply_audio(GameManager.current_weather, false)
	GameManager.weather_changed.connect(_on_weather_changed)

func _on_weather_changed(new_weather: String) -> void:
	_apply_audio(new_weather, true)

func _apply_audio(weather: String, animated: bool) -> void:
	if not rain_audio or not VOLUME_DB.has(weather):
		return
	var target_volume: float = VOLUME_DB[weather]
	if _tween:
		_tween.kill()
	if not animated:
		rain_audio.volume_db = target_volume
		return
	_tween = create_tween()
	_tween.tween_property(rain_audio, "volume_db", target_volume, TRANSITION_DURATION).set_trans(Tween.TRANS_SINE)
