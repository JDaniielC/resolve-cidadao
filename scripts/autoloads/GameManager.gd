# scripts/autoloads/GameManager.gd
extends Node

signal stage_changed(new_stage: int)
signal choice_made(option_index: int, is_correct: bool)

var current_stage: int = 1
var is_game_paused: bool = false

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
