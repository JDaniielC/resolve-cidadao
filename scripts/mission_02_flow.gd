# scripts/mission_02_flow.gd
# Roteiro scriptado da Missão 2 "Teimosia que Salva" (Plano 2), encadeando os
# sistemas já prontos (Cutscene, Popups, diálogos, ChoicePanel, PhoneMenu,
# MissionComplete, Notifications).
#
# NÃO é autoload — chame a função estática: Mission02Flow.play()
# Serve para validar a lógica/roteiro de ponta a ponta SEM depender de cenas
# andáveis. Depois, cada "beat" pode virar um gatilho espacial nas cenas reais
# (cada passo abaixo já está encapsulado e reutilizável).
class_name Mission02Flow
extends RefCounted

const LUCAS_DIALOGUE := "res://dialogues/missao_02/lucas.dialogue"
const SEVERINO_DIALOGUE := "res://dialogues/missao_02/seu_severino.dialogue"

static func _tree() -> SceneTree:
	return Engine.get_main_loop() as SceneTree

static func _node(rel_path: String) -> Node:
	var scene := _tree().current_scene
	if scene == null:
		return null
	return scene.get_node_or_null(rel_path)

static func _play_dialogue(path: String, title: String) -> void:
	var res := load(path)
	if res == null:
		push_warning("Mission02Flow: diálogo não encontrado: %s" % path)
		return
	DialogueManager.show_dialogue_balloon(res, title)
	await DialogueManager.dialogue_ended

## Espera o jogador escolher a opção CORRETA no ChoicePanel.
static func _await_correct_choice() -> void:
	while true:
		var result: Array = await GameManager.choice_made
		if result.size() >= 2 and result[1]:
			return

## Roda a missão 2 inteira, em sequência.
static func play() -> void:
	# 1. Gatilho de transição + alerta do choro
	await Cutscene.lock_input_for(1.0)
	await Popups.show_alert(
		"Você ouve o choro de uma criança ecoando logo à frente na rua alagada. Vá ver o que está acontecendo!",
		"Entendido"
	)

	# 2. Encontro com o Lucas
	await _play_dialogue(LUCAS_DIALOGUE, "intro")

	# 3. Seu Severino — fala inicial
	await _play_dialogue(SEVERINO_DIALOGUE, "intro")

	# 4. Escolha A/B/C (espera a correta; o ChoicePanel trata A/B sozinho)
	var choice_panel := _node("UILayer/ChoicePanel")
	if choice_panel:
		choice_panel.show_choice("severino_approach")
		await _await_correct_choice()
		await _tree().create_timer(1.4).timeout  # deixa o painel fechar

	# 5. Dilema do rádio de pilha
	await _play_dialogue(SEVERINO_DIALOGUE, "radio")

	# 6. Menu de contatos (desafio) — espera acionar a Defesa Civil
	var phone := _node("UILayer/PhoneMenu")
	if phone:
		phone.start_contact_challenge("defesa_civil")
		await phone.contact_challenge_succeeded

	# 7. Conclusão + SMS abrindo a próxima etapa (abrigo)
	var mission_complete := _node("MissionComplete")
	if mission_complete and mission_complete.has_method("show_mission_complete"):
		mission_complete.show_mission_complete()
	Notifications.notify_sms(
		"Prefeitura / Coordenação",
		"Excelente trabalho de cidadania. Dirija-se ao Abrigo Municipal na Escola Pública para a triagem das famílias."
	)
