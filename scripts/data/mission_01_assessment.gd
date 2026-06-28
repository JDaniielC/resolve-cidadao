extends RefCounted
class_name Mission01Assessment

const TITLE := "Prova da Missão 1 - A chuva não para"

## Texto das questoes. Layout (posicao, linhas, fontes padrao): scripts/ui/mission_assessment.gd → LAYOUT
##
## Campos opcionais por questao (so se precisar sobrescrever o LAYOUT):
##   font_size, min_height, content_width, option_font_size, option_line_height
## Use \n em "text" ou em "options" para quebra de linha manual.

const QUESTIONS: Array[Dictionary] = [
	{
		"text": "Durante uma enchente,\nqual órgão orienta a população\ne indica locais seguros?",
		"font_size": 24,
		"min_height": 96,
		"content_width": 300,
		"option_font_size": 22,
		"option_line_height": 38,
		"options": [
			"A) COMPESA",
			"B) Defesa Civil",
			"C) Procon",
		],
		"correct_index": 1,
	},
	{
		"text": "Qual é a principal função de um \nabrigo temporário em uma emergência?",
		"font_size": 23,
		"min_height": 88,
		"content_width": 400,
		"option_font_size": 21,
		"option_line_height": 50,
		"options": [
			"A) Servir como moradia definitiva",
			"B) Oferecer local seguro enquanto as famílias \nrecebem apoio",
			"C) Distribuir alimentos para toda a \npopulação",
		],
		"correct_index": 1,
	},
	{
		"text": "Qual é o principal objetivo\ndo programa de Aluguel Social?",
		"font_size": 23,
		"min_height": 72,
		"content_width": 300,
		"option_font_size": 21,
		"option_line_height": 38,
		"options": [
			"A) Financiar a compra da casa própria",
			"B) Apoiar famílias vulneráveis\ncom o pagamento do aluguel",
			"C) Pagar contas básicas da residência",
		],
		"correct_index": 1,
	},
	{
		"text": "Após identificar direito ao Aluguel Social,\nqual costuma ser o primeiro passo?",
		"font_size": 22,
		"min_height": 72,
		"content_width": 300,
		"option_font_size": 21,
		"option_line_height": 40,
		"options": [
			"A) Comprar um imóvel para a família",
			"B) Verificar se a família atende\naos critérios do programa",
			"C) Solicitar indenização pelos danos",
		],
		"correct_index": 1,
	},
]
