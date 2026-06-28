# scripts/autoloads/GameManager.gd
extends Node

signal stage_changed(new_stage: int)
signal choice_made(option_index: int, is_correct: bool)
signal satisfaction_changed(new_value: float)
signal time_changed(hour: int, minute: int)
signal weather_changed(new_weather: String)

var current_stage: int = 1
var is_game_paused: bool = false
## Marca o fim da missão/jogo. Quando true, a satisfação para de decair.
var game_completed: bool = false
var assessment_completed: bool = false

# Satisfaction system
## Quanto de satisfação a cidade perde por hora de jogo decorrida.
const SATISFACTION_DECAY_PER_HOUR: float = 1.0
var satisfaction: float = 90.0:
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

var water_solved: bool = false
var housing_solved: bool = false

const PROGRESS_PATH := "user://progress.cfg"
## Caminho da cena de nível ativa (para restaurar o local certo ao continuar).
var current_level_path: String = "res://scenes/levels/rain_street.tscn"

var stage_data = {
	1: {"name": "Primeiro Controle", "objective": "Aproxime-se de Dona Maria"},
	2: {"name": "Primeiro NPC", "objective": "Converse com Dona Maria"},
	3: {"name": "Identificar Necessidade", "objective": "O que Dona Maria precisa agora?"},
	4: {"name": "Celular da Cidade", "objective": "Abra o celular e conheça os serviços da cidade"},
	5: {"name": "Encontrar Abrigo", "objective": "Consulte o Registro de Problemas para localizar o abrigo"},
	6: {"name": "Ir ao Abrigo", "objective": "Encontre o abrigo temporário na escola"},
	7: {"name": "Abrigo Temporário", "objective": "Converse com o funcionário do abrigo"},
	8: {"name": "Passagem de Tempo", "objective": "Saia do abrigo para ver os estragos no bairro"},
	9: {"name": "Rua Destruída", "objective": "Converse com Dona Maria sobre a casa dela"},
	10: {"name": "Direito à Moradia", "objective": "Converse com a Agente Social"},
	11: {"name": "Final da Missão", "objective": "Explique o Aluguel Social para Dona Maria"}
}

var time_accumulator: float = 0.0

func _ready():
	print("GameManager initialized at stage %d" % current_stage)
	# Auto-save do progresso sempre que o stage avança.
	stage_changed.connect(func(_new_stage): save_progress())
	if current_stage >= 9:
		current_weather = "Nublado"

func _process(delta: float):
	if is_game_paused:
		return
	time_accumulator += delta
	if time_accumulator >= 1.0: # Every 1 second, game time advances by 1 minute
		time_accumulator = 0.0
		advance_time(1)

func advance_stage():
	if current_stage < stage_data.size():
		current_stage += 1
		if current_stage >= 9:
			set_weather("Nublado")
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

## Resolve um registro de problema: aumenta a satisfação da cidade e dispara a
## notificação correspondente. Use em cada ponto de resolução para manter o
## comportamento consistente (a satisfação sobe e o jogador é avisado).
func resolve_problem(label: String, amount: float) -> void:
	add_satisfaction(amount)
	Notifications.notify_resolved(label, amount)

## Penaliza a satisfação por uma escolha negativa: baixa a satisfação E avisa o
## jogador com um toast. O decaimento passivo por tempo continua usando
## remove_satisfaction() direto, de propósito, para NÃO notificar a cada segundo.
func penalize_satisfaction(amount: float, reason := "") -> void:
	remove_satisfaction(amount)
	Notifications.notify_penalty(amount, reason)

## Set a specific time (useful for mission transitions)
func set_game_time(hour: int, minute: int):
	game_hour = hour
	game_minute = minute
	time_changed.emit(game_hour, game_minute)

## Advance time by a number of minutes
func advance_time(minutes: int):
	game_minute += minutes
	# A satisfação da cidade decai com o tempo, exceto após o fim da missão.
	if not game_completed:
		remove_satisfaction(SATISFACTION_DECAY_PER_HOUR / 60.0 * minutes)

## Marca a missão/jogo como concluído — congela o decaimento da satisfação.
func complete_game() -> void:
	game_completed = true

## Set the weather explicitly — use this in each new map/mission
## to define the climate that fits the narrative context.
## Examples:
##   GameManager.set_weather("Chuva Forte")  # enchente em curso
##   GameManager.set_weather("Nublado")      # pós-enchente, cinzento
##   GameManager.set_weather("Limpo")        # bairro recuperado, sol voltando
##   GameManager.set_weather("Estiagem")     # missão sobre seca
func set_weather(weather: String) -> void:
	current_weather = weather

# --- Persistência do progresso da história ---

## Grava o progresso atual (stage, satisfação, tempo, clima, nível) em disco.
func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "stage", current_stage)
	cfg.set_value("progress", "satisfaction", satisfaction)
	cfg.set_value("progress", "game_hour", game_hour)
	cfg.set_value("progress", "game_minute", game_minute)
	cfg.set_value("progress", "weather", current_weather)
	cfg.set_value("progress", "water_solved", water_solved)
	cfg.set_value("progress", "game_completed", game_completed)
	cfg.set_value("progress", "level", current_level_path)
	cfg.save(PROGRESS_PATH)

## Restaura o progresso salvo (chamado pelo "Continuar" antes de abrir o jogo).
func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PROGRESS_PATH) != OK:
		return
	current_stage = cfg.get_value("progress", "stage", 1)
	satisfaction = cfg.get_value("progress", "satisfaction", 90.0)
	game_hour = cfg.get_value("progress", "game_hour", 8)
	game_minute = cfg.get_value("progress", "game_minute", 30)
	current_weather = cfg.get_value("progress", "weather", "Chuva Forte")
	water_solved = cfg.get_value("progress", "water_solved", false)
	game_completed = cfg.get_value("progress", "game_completed", false)
	current_level_path = cfg.get_value("progress", "level", current_level_path)
	if current_stage >= 9:
		current_weather = "Nublado"

## Existe um save de progresso?
func has_save() -> bool:
	return FileAccess.file_exists(PROGRESS_PATH)

## Apaga o save (usado em "Novo Jogo").
func clear_save() -> void:
	if FileAccess.file_exists(PROGRESS_PATH):
		DirAccess.remove_absolute(PROGRESS_PATH)

## Volta o progresso ao início (usado em "Novo Jogo").
func reset_progress() -> void:
	current_stage = 1
	satisfaction = 90.0
	game_hour = 8
	game_minute = 30
	current_weather = "Chuva Forte"
	water_solved = false
	game_completed = false
	assessment_completed = false
	current_level_path = "res://scenes/levels/rain_street.tscn"
