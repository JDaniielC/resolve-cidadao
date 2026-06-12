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
			{
				"text": "Encontrar emprego",
				"correct": false,
				"feedback": "Ela não falou sobre trabalho. Repense o que ela contou sobre a chuva e a casa."
			},
			{
				"text": "Procurar abrigo temporário",
				"correct": true,
				"feedback": "Isso mesmo! A Defesa Civil abriu um abrigo e ficar em casa está ficando perigoso."
			},
			{
				"text": "Ir ao hospital",
				"correct": false,
				"feedback": "Ela não parece ferida ou doente. O problema agora é a enchente dentro de casa."
			}
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
