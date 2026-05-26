# dialogues/dona_maria_data.gd
extends Node

var dialogues = {
	"intro": [
		{"character": "Dona Maria", "text": "A água subiu muito rápido..."},
		{"character": "Dona Maria", "text": "A Defesa Civil mandou a gente sair."},
		{"character": "Dona Maria", "text": "Disseram que abriram um abrigo."}
	],
	"choice_housing": {
		"question": "O que Dona Maria precisa agora?",
		"options": [
			{"text": "Encontrar emprego", "correct": false},
			{"text": "Procurar abrigo temporário", "correct": true},
			{"text": "Ir ao hospital", "correct": false}
		]
	}
}

func get_dialogue(dialogue_id: String) -> Array:
	if dialogue_id in dialogues:
		return dialogues[dialogue_id]
	return []

func get_choice(choice_id: String) -> Dictionary:
	if choice_id in dialogues:
		return dialogues[choice_id]
	return {}
