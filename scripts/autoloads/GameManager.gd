# scripts/autoloads/GameManager.gd
extends Node

signal stage_changed(new_stage: int)
signal choice_made(option_index: int, is_correct: bool)
signal satisfaction_changed(new_value: float)
signal time_changed(hour: int, minute: int)
signal weather_changed(new_weather: String)

var current_stage: int = 1
var is_game_paused: bool = false

# Satisfaction system
var satisfaction: float = 50.0:
	set(value):
		satisfaction = clamp(value, 0.0, 100.0)
		satisfaction_changed.emit(satisfaction)

# Time system
var game_hour: int = 8
var game_minute: int = 30:
	set(value):
		game_minute = value
		if game_minute >= 60:
			game_minute = 0
			game_hour = (game_hour + 1) % 24
		time_changed.emit(game_hour, game_minute)

# Weather system
var current_weather: String = "Chuva Forte":
	set(value):
		current_weather = value
		weather_changed.emit(current_weather)

var stage_data = {
	1: {"name": "Primeiro Controle", "objective": "Aproxime-se de Dona Maria"},
	2: {"name": "Primeiro NPC", "objective": "Converse com Dona Maria"},
	3: {"name": "Identificar Necessidade", "objective": "Responda corretamente"},
	4: {"name": "Desbloqueio do Celular", "objective": "Explore o celular da cidade"}
}

func _ready():
	print("GameManager initialized at stage %d" % current_stage)

func advance_stage():
	if current_stage < 4:
		current_stage += 1
		stage_changed.emit(current_stage)
		print("Advanced to stage %d: %s" % [current_stage, stage_data[current_stage]["name"]])

func get_objective() -> String:
	return stage_data[current_stage]["objective"]

func pause_game():
	is_game_paused = true

func resume_game():
	is_game_paused = false

func add_satisfaction(amount: float):
	satisfaction += amount

func remove_satisfaction(amount: float):
	satisfaction -= amount

## Set a specific time (useful for mission transitions)
func set_game_time(hour: int, minute: int):
	game_hour = hour
	game_minute = minute
	time_changed.emit(game_hour, game_minute)

## Advance time by a number of minutes
func advance_time(minutes: int):
	game_minute += minutes
