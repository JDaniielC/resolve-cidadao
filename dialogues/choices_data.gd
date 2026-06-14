# dialogues/choices_data.gd
# Registro central das escolhas (puzzles de múltipla escolha) usados pelo ChoicePanel.
# Cada escolha tem o formato:
#   { "question": String, "options": [ { "text": String, "correct": bool, "feedback": String } ] }
# Para adicionar um novo puzzle, basta incluir uma entrada em `choices`.
extends RefCounted

var choices := {
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
	},
	"choice_aluguel_social": {
		"question": "Que programa pode ajudar famílias que perderam a moradia?",
		"options": [
			{
				"text": "Vale-transporte",
				"correct": false,
				"feedback": "O vale-transporte ajuda no deslocamento diário, não com a perda da moradia."
			},
			{
				"text": "Aluguel social",
				"correct": true,
				"feedback": "Isso! O aluguel social é um auxílio para famílias que ficaram sem moradia após a enchente."
			},
			{
				"text": "Tarifa social",
				"correct": false,
				"feedback": "A tarifa social dá desconto em contas como água e luz, mas não resolve a falta de moradia."
			}
		]
	},
	"choice_moradia_comprometida": {
		"question": "Que programa pode ajudar famílias que perderam a moradia?",
		"options": [
			{
				"text": "Vale transporte",
				"correct": false,
				"feedback": "O vale transporte ajuda com custos de locomoção, não com moradia."
			},
			{
				"text": "Aluguel social",
				"correct": true,
				"feedback": "Isso mesmo! O aluguel social é um auxílio oferecido em situações emergenciais para moradia."
			},
			{
				"text": "Tarifa social",
				"correct": false,
				"feedback": "A tarifa social dá descontos na conta de luz ou água, mas não resolve a falta de moradia."
			}
		]
	},
	"severino_approach": {
		"question": "Como convencer o Seu Severino a sair de casa?",
		"options": [
			{
				"text": "\"O senhor está sendo egoísta! Seu neto está chorando na chuva por sua causa.\"",
				"correct": false,
				"satisfaction": -5.0,
				"feedback": "Ele se fecha ainda mais. Acusar não ajuda — tente entender o lado dele."
			},
			{
				"text": "\"Se não sair agora, vou ter que chamar a polícia para te tirar à força.\"",
				"correct": false,
				"lesson": "Seu Severino (indignado): \"Chamar a polícia para um velho na própria casa?! Eu não sou criminoso, rapaz! Trabalhei honestamente a vida inteira para construir este teto com o meu suor. Vocês mais novos acham que tudo se resolve na base da força, sem nenhum respeito pela história de quem mora aqui.\"",
				"satisfaction": -8.0,
					"lesson_button": "Pedir Desculpas"
			},
			{
				"text": "\"O risco aqui é de deslizamento do morro. Bens materiais a gente recupera, sua vida não.\"",
				"correct": true,
				"feedback": "Correto! Priorizar a vida e explicar o risco técnico (deslizamento) é a forma mais eficaz e respeitosa de agir."
			}

		]
	}
}

func get_choice(choice_id: String) -> Dictionary:
	return choices.get(choice_id, {})
