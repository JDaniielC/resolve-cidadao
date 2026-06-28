# scripts/autoloads/GameManager.gd
extends Node

signal stage_changed(new_stage: int)
signal choice_made(option_index: int, is_correct: bool)
signal satisfaction_changed(new_value: float)
signal time_changed(hour: int, minute: int)
signal weather_changed(new_weather: String)

var radio_collected: bool = false
var current_stage: int = 1
var is_game_paused: bool = false
## Marca o fim da missão/jogo. Quando true, a satisfação para de decair.
var game_completed: bool = false

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
var severino_saved: bool = false  # novo: marca Seu Severino resgatado

const PROGRESS_PATH := "user://progress.cfg"
## Caminho da cena de nível ativa (para restaurar o local certo ao continuar).
var current_level_path: String = "res://scenes/levels/rain_street.tscn"

var stage_data = {
	# ── Missão 1: A Chuva Não Para ──────────────────────────────────────────
	1:  {"name": "Primeiro Controle",   "objective": "Aproxime-se de Dona Maria"},
	2:  {"name": "Primeiro NPC",        "objective": "Converse com Dona Maria"},
	3:  {"name": "Identificar Necessidade", "objective": "O que Dona Maria precisa agora?"},
	4:  {"name": "Celular da Cidade",   "objective": "Abra o celular e conheça os serviços da cidade"},
	5:  {"name": "Encontrar Abrigo",    "objective": "Consulte o Registro de Problemas para localizar o abrigo"},
	6:  {"name": "Ir ao Abrigo",        "objective": "Encontre o abrigo temporário na escola"},
	7:  {"name": "Abrigo Temporário",   "objective": "Converse com o funcionário do abrigo"},
	8:  {"name": "Passagem de Tempo",   "objective": "Saia do abrigo para ver os estragos no bairro"},
	9:  {"name": "Rua Destruída",       "objective": "Converse com Dona Maria sobre a casa dela"},
	10: {"name": "Direito à Moradia",   "objective": "Converse com a Agente Social"},
	11: {"name": "Final da Missão 1",   "objective": "Explique o Aluguel Social para Dona Maria"},
	# ── Missão 2: Teimosia que Salva ────────────────────────────────────────
	12: {"name": "Missão 2 — Início",   "objective": "Suba em direção à encosta e procure por Lucas"},
	13: {"name": "Encontrou Lucas",     "objective": "Converse com Lucas sobre Seu Severino"},
	14: {"name": "Convencer Severino",  "objective": "Convença Seu Severino a sair de casa"},
	15: {"name": "Rádio de Pilha",         "objective": "Pegue o rádio do Seu Severino"},
	16: {"name": "Conversa Final",          "objective": "Volte falar com Seu Severino"},
	17: {"name": "Chamar Defesa Civil",     "objective": "Use o celular para acionar a Defesa Civil"},
	18: {"name": "Missão 2 — Concluída",   "objective": "Missão concluída! Vá ao Abrigo Municipal"},
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
	if time_accumulator >= 1.0:
		time_accumulator = 0.0
		advance_time(1)

## Avança para o próximo stage, desde que ele exista no stage_data.
## Corrigido: usa .has() em vez de .size() para não bloquear nos stages novos.
func advance_stage():
	if stage_data.has(current_stage + 1):
		current_stage += 1
		if current_stage >= 9:
			set_weather("Nublado")
		stage_changed.emit(current_stage)
		print("Advanced to stage %d: %s" % [current_stage, stage_data[current_stage]["name"]])
	else:
		print("GameManager: já está no stage final (%d)." % current_stage)

func get_objective() -> String:
	if stage_data.has(current_stage):
		return stage_data[current_stage]["objective"]
	return ""

func pause_game():
	is_game_paused = true

func resume_game():
	is_game_paused = false

func add_satisfaction(amount: float):
	satisfaction += amount

func remove_satisfaction(amount: float):
	satisfaction -= amount

## Resolve um registro de problema: aumenta a satisfação da cidade e dispara a
## notificação correspondente.
func resolve_problem(label: String, amount: float) -> void:
	add_satisfaction(amount)
	Notifications.notify_resolved(label, amount)

## Penaliza a satisfação por uma escolha negativa.
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
	if not game_completed:
		remove_satisfaction(SATISFACTION_DECAY_PER_HOUR / 60.0 * minutes)

## Marca a missão/jogo como concluído — congela o decaimento da satisfação.
func complete_game() -> void:
	game_completed = true

## Set the weather explicitly
func set_weather(weather: String) -> void:
	current_weather = weather

# ── Persistência do progresso ────────────────────────────────────────────────

## Grava o progresso atual em disco.
func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "stage", current_stage)
	cfg.set_value("progress", "satisfaction", satisfaction)
	cfg.set_value("progress", "game_hour", game_hour)
	cfg.set_value("progress", "game_minute", game_minute)
	cfg.set_value("progress", "weather", current_weather)
	cfg.set_value("progress", "water_solved", water_solved)
	cfg.set_value("progress", "housing_solved", housing_solved)
	cfg.set_value("progress", "severino_saved", severino_saved)
	cfg.set_value("progress", "game_completed", game_completed)
	cfg.set_value("progress", "level", current_level_path)
	cfg.save(PROGRESS_PATH)

## Restaura o progresso salvo.
func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PROGRESS_PATH) != OK:
		return
	current_stage   = cfg.get_value("progress", "stage", 1)
	satisfaction    = cfg.get_value("progress", "satisfaction", 90.0)
	game_hour       = cfg.get_value("progress", "game_hour", 8)
	game_minute     = cfg.get_value("progress", "game_minute", 30)
	current_weather = cfg.get_value("progress", "weather", "Chuva Forte")
	water_solved    = cfg.get_value("progress", "water_solved", false)
	housing_solved  = cfg.get_value("progress", "housing_solved", false)
	severino_saved  = cfg.get_value("progress", "severino_saved", false)
	game_completed  = cfg.get_value("progress", "game_completed", false)
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
	current_stage      = 1
	satisfaction       = 90.0
	game_hour          = 8
	game_minute        = 30
	current_weather    = "Chuva Forte"
	water_solved       = false
	housing_solved     = false
	severino_saved     = false
	game_completed     = false
	current_level_path = "res://scenes/levels/rain_street.tscn"
	radio_collected = false
