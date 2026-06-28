extends Node2D
## Controller script for MainGame scene that manages pause menu integration and input handling

# Preload pause menu scene
var pause_menu_scene = preload("res://scenes/ui/menus/pause_menu.tscn")

const DRY_LEVEL_PATHS: Array[String] = [
	"res://scenes/levels/shelter.tscn",
	"res://scenes/levels/destructed_street.tscn",
]

const RAIN_VOLUME_DB := {
	"Chuva Forte": 0.0,
	"Chuva Leve": -14.0,
	"Nublado": -80.0,
	"Limpo": -80.0,
	"Estiagem": -80.0,
}

var intro_overlay: ColorRect
var intro_layer: CanvasLayer

func _enter_tree() -> void:
	if GameManager.current_stage <= 1:
		_create_intro_overlay()

func _ready() -> void:
	# Connect to MenuController pause state signal
	MenuController.menu_state_changed.connect(_on_menu_state_changed)
	SceneManager.load_complete.connect(_on_level_loaded)
	await get_tree().process_frame
	_apply_camera_bounds()
	_apply_level_rain()

	# Continuando de um save: pula a intro e restaura o nível salvo.
	if GameManager.current_stage > 1:
		_resume_from_save()
		return

	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	# Initial narrative popup
	await Popups.show_alert(
		"As fortes chuvas em Recife atingiram níveis críticos. Como Agente Social, sua missão é garantir a segurança e os direitos da comunidade do Coque.",
		"Entendido",
		"Alerta de Emergência"
	)

	_start_rain_ambience()
	
	await get_tree().create_timer(1.0).timeout
	
	# Disable player input during the intro dialogue
	for player in Globals.get_players():
		if player is PlayerEntity:
			player.input_enabled = false
			
	DialogueManager.show_dialogue_balloon(
		load("res://dialogues/missao_01/radio.dialogue"),
		"start"
	)

func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource and resource.resource_path.ends_with("radio.dialogue"):
		# Smoothly fade out the dark overlay
		if is_instance_valid(intro_overlay):
			var tween = create_tween()
			tween.tween_property(intro_overlay, "color", Color(0, 0, 0, 0), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			await tween.finished
		if is_instance_valid(intro_layer):
			intro_layer.queue_free()
		
		# Start the interactive HUD tutorial
		var hud = $HUD
		Notifications.notify_problem("Transmissão de rádio alerta para risco de inundação!", "📢")
		if hud and hud.has_method("start_tutorial"):
			hud.start_tutorial()
		else:
			# Fallback if no tutorial is found
			for player in Globals.get_players():
				if player is PlayerEntity:
					player.input_enabled = true

func _input(event: InputEvent) -> void:
	# Only handle ESC if game is not already paused
	if event.is_action_pressed("ui_cancel") and not MenuController.is_paused():
		_open_pause_menu()
		get_tree().root.set_input_as_handled()

func _open_pause_menu() -> void:
	## Open pause menu by toggling pause state and instantiating pause menu
	MenuController.toggle_pause()
	add_child(pause_menu_scene.instantiate())

const WRAP_UP_INTRO_TITLE := "Avaliação do Módulo"
const WRAP_UP_INTRO_MESSAGE := (
	"Você concluiu este módulo!\n\n"
	+ "Agora é hora de consolidar o que você aprendeu. Responda à avaliação "
	+ "para revisar os principais conhecimentos e desbloquear sua próxima jornada."
)
const WRAP_UP_INTRO_BUTTON := "Iniciar Avaliação"
const WRAP_UP_ASSESSMENT_DELAY := 3.5

var _wrap_up_running := false

func swap_level(scene_path: String, outgoing: Node) -> void:
	_run_level_swap(scene_path, outgoing)

## Diálogo final da missão 1: intro (Popups) -> avaliação -> parabéns.
func begin_mission_wrap_up() -> void:
	if _wrap_up_running:
		return
	_wrap_up_running = true
	_run_mission_wrap_up()

func _run_mission_wrap_up() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

	# Tempo para ler toasts/popups anteriores (ex.: problema resolvido) antes da avaliacao.
	await get_tree().create_timer(WRAP_UP_ASSESSMENT_DELAY).timeout

	await Popups.show_alert(WRAP_UP_INTRO_MESSAGE, WRAP_UP_INTRO_BUTTON, WRAP_UP_INTRO_TITLE)

	var mission_complete := get_node_or_null("MissionComplete")
	var mission_assessment := get_node_or_null("MissionAssessment")
	if mission_assessment and mission_assessment.has_method("begin_quiz"):
		mission_assessment.begin_quiz(mission_complete)
	else:
		push_error("MainGame: MissionAssessment nao encontrado ou sem begin_quiz().")

	_wrap_up_running = false

func _run_level_swap(scene_path: String, outgoing: Node) -> void:
	await Cutscene.fade_out(0.5)
	var incoming: Node = load(scene_path).instantiate()
	if incoming == null:
		push_error("Failed to load level: %s" % scene_path)
		await Cutscene.fade_in(0.5)
		return
	add_child(incoming)
	if outgoing and is_instance_valid(outgoing):
		outgoing.queue_free()
	await get_tree().process_frame
	var camera: GameCamera = $GameCamera2D
	if camera:
		camera.refresh_target()
		_apply_camera_bounds()
	var level_path := incoming.scene_file_path
	if level_path != "":
		GameManager.current_level_path = level_path
	GameManager.save_progress()
	_apply_level_rain()
	await Cutscene.fade_in(0.5)

func _create_intro_overlay() -> void:
	if intro_layer:
		return
	intro_layer = CanvasLayer.new()
	intro_layer.layer = 1 # Above game (0) but below UILayer (2)
	add_child(intro_layer)

	intro_overlay = ColorRect.new()
	intro_overlay.color = Color.BLACK
	intro_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	intro_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	intro_layer.add_child(intro_overlay)

func _start_rain_ambience() -> void:
	var rain_player := get_node_or_null("AudioStreamPlayer") as AudioStreamPlayer
	if rain_player and not rain_player.playing:
		rain_player.play()

## Continuando de um save: restaura o nível salvo e devolve o controle ao jogador.
func _resume_from_save() -> void:
	var default_level := "res://scenes/levels/rain_street.tscn"
	var target := GameManager.current_level_path
	if target != "" and target != default_level:
		var current_level := _get_active_level()
		if current_level:
			swap_level(target, current_level)
	for player in Globals.get_players():
		if player is PlayerEntity:
			player.input_enabled = true
	_start_rain_ambience()

func _on_level_loaded(_loaded_scene: Node) -> void:
	var camera: GameCamera = $GameCamera2D
	if camera:
		camera.refresh_target()
		_apply_camera_bounds()
	_apply_level_rain()

func _apply_camera_bounds() -> void:
	var camera: GameCamera = $GameCamera2D
	if not camera:
		return

	var level := _get_active_level()
	if level:
		camera.apply_level_bounds(level)
	else:
		camera.clear_limits()

func _get_active_level() -> Node:
	for child in get_children():
		if child is CanvasLayer or child is AudioStreamPlayer:
			continue
		if child.name in ["HUD", "MissionComplete", "MissionAssessment", "GameCamera2D", "ScreenRain"]:
			continue
		if child is Node2D:
			return child
	return null

func _apply_level_rain() -> void:
	var level := _get_active_level()
	var level_path := level.scene_file_path if level else ""
	var suppress_rain := level_path in DRY_LEVEL_PATHS

	var screen_rain := get_node_or_null("ScreenRain")
	if screen_rain and screen_rain.has_method("set_suppressed"):
		screen_rain.set_suppressed(suppress_rain)

	var rain_player := get_node_or_null("AudioStreamPlayer") as AudioStreamPlayer
	if not rain_player:
		return
	if suppress_rain:
		rain_player.volume_db = -80.0
	elif RAIN_VOLUME_DB.has(GameManager.current_weather):
		rain_player.volume_db = RAIN_VOLUME_DB[GameManager.current_weather]

func _on_menu_state_changed(_is_paused: bool) -> void:
	## Handle menu state changes (pause/resume).
	##
	## Mouse routing is handled automatically by the engine: the pause menu is
	## a CanvasLayer overlay whose Control nodes capture clicks while it exists,
	## and clicks fall through to the game once it is freed. (`mouse_filter` is a
	## per-Control property, not a method on the global `Input` singleton, so the
	## previous `Input.set_mouse_filter(...)` calls were invalid and never ran.)
	pass
