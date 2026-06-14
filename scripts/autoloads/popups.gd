# scripts/autoloads/popups.gd
# Sistema de pop-up de alerta narrativo reutilizável (modal bloqueante).
# Diferente das notificações (passageiras), o popup escurece o fundo, captura os
# cliques, pausa o jogo e ESPERA o jogador escolher um botão. Uso via autoload:
#   await Popups.show_alert("Você ouve o choro de uma criança...", "Entendido")
#   var idx = await Popups.ask("Tem certeza?", ["Sim", "Não"])
# Constrói a própria UI em código (não depende de cenas/assets).
extends CanvasLayer

signal _closed(index: int)

const ACCENT := Color("6AD8FF")

var _busy := false
var _was_paused := false
var _overlay: ColorRect

func _ready() -> void:
	layer = 105  # acima dos toasts (100), abaixo do MissionComplete (110)
	process_mode = Node.PROCESS_MODE_ALWAYS  # botões funcionam mesmo com o jogo pausado

## Alerta de um botão. Use `await` apenas para continuar quando o jogador fechar.
## Retorna 0 quando fechado (ou -1 se já houver um popup aberto).
func show_alert(message: String, button_text := "Entendido", title := "") -> int:
	return await ask(message, [button_text], title)

## Modal com uma ou mais opções. Retorna o índice do botão escolhido
## (ou -1 se já houver um popup aberto).
func ask(message: String, buttons: Array, title := "") -> int:
	if _busy:
		push_warning("Popups: já há um popup aberto; chamada ignorada.")
		return -1
	if buttons.is_empty():
		buttons = ["Entendido"]
	_busy = true

	_was_paused = get_tree().paused
	get_tree().paused = true

	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.6)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP  # bloqueia cliques no mundo atrás
	add_child(_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_stylebox())
	panel.custom_minimum_size = Vector2(460, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, 20)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	if title != "":
		var title_label := Label.new()
		title_label.text = title
		title_label.add_theme_font_size_override("font_size", 20)
		title_label.add_theme_color_override("font_color", ACCENT)
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(title_label)

	var msg_label := Label.new()
	msg_label.text = message
	msg_label.add_theme_font_size_override("font_size", 16)
	msg_label.add_theme_color_override("font_color", Color(0.9, 0.92, 0.95))
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_label.custom_minimum_size = Vector2(420, 0)
	vbox.add_child(msg_label)

	var buttons_row := HBoxContainer.new()
	buttons_row.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons_row.add_theme_constant_override("separation", 12)
	vbox.add_child(buttons_row)

	for i in range(buttons.size()):
		var btn := Button.new()
		btn.text = str(buttons[i])
		btn.custom_minimum_size = Vector2(140, 44)
		btn.pressed.connect(_on_button_pressed.bind(i))
		buttons_row.add_child(btn)

	_overlay.modulate.a = 0.0
	var t := _overlay.create_tween()
	t.tween_property(_overlay, "modulate:a", 1.0, 0.2)

	var index: int = await _closed
	return index

func _on_button_pressed(index: int) -> void:
	if _overlay == null:
		return
	var overlay := _overlay
	_overlay = null
	_busy = false
	get_tree().paused = _was_paused

	var t := overlay.create_tween()
	t.tween_property(overlay, "modulate:a", 0.0, 0.2)
	t.tween_callback(overlay.queue_free)

	_closed.emit(index)

func _make_stylebox() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.10, 0.12, 0.16, 0.98)
	sb.set_corner_radius_all(10)
	sb.set_border_width_all(1)
	sb.border_color = Color(0.3, 0.5, 0.6, 0.5)
	return sb

# --- Auto-teste opcional (só em build de debug; remover quando ligar no fluxo) ---
func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M:
		_debug_demo()

func _debug_demo() -> void:
	var i := await ask(
		"Você ouve o choro de uma criança ecoando logo à frente na rua alagada. Vá ver o que está acontecendo!",
		["Entendido", "Agora não"],
		"Alerta"
	)
	print("[Popups] Demo escolheu índice: %d" % i)
