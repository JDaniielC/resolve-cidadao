# scripts/autoloads/notifications.gd
# Sistema de notificações/toast reutilizável.
# Mostra avisos passageiros no topo-centro da tela. Pode ser chamado de qualquer
# script via autoload: Notifications.show_toast(...), notify_problem(...), etc.
# Constrói a própria UI em código (não depende de cenas/assets).
extends CanvasLayer

const DEFAULT_DURATION := 3.5
const MAX_VISIBLE := 4

const ACCENTS := {
	"info":    Color("6AD8FF"),
	"success": Color("40FF8D"),
	"warning": Color("FFB454"),
	"sms":     Color("9AD0FF"),
}

var _stack: VBoxContainer

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS  # anima mesmo com get_tree().paused

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_stack = VBoxContainer.new()
	_stack.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_stack.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_stack.position.y = 16
	_stack.add_theme_constant_override("separation", 8)
	_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_stack)

func show_toast(message: String, title := "", icon := "", duration := DEFAULT_DURATION, kind := "info") -> void:
	var accent: Color = ACCENTS.get(kind, ACCENTS["info"])

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_stylebox(accent))
	panel.custom_minimum_size = Vector2(360, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var margin := MarginContainer.new()
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_%s" % side, 14)
	for side in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, 10)
	panel.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	margin.add_child(hbox)

	if icon != "":
		var icon_label := Label.new()
		icon_label.text = icon
		icon_label.add_theme_font_size_override("font_size", 24)
		hbox.add_child(icon_label)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(text_box)

	if title != "":
		var title_label := Label.new()
		title_label.text = title
		title_label.add_theme_font_size_override("font_size", 15)
		title_label.add_theme_color_override("font_color", accent)
		text_box.add_child(title_label)

	var msg_label := Label.new()
	msg_label.text = message
	msg_label.add_theme_font_size_override("font_size", 14)
	msg_label.add_theme_color_override("font_color", Color(0.88, 0.9, 0.94))
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg_label.custom_minimum_size = Vector2(300, 0)
	text_box.add_child(msg_label)

	_stack.add_child(panel)
	while _stack.get_child_count() > MAX_VISIBLE:
		_stack.get_child(0).queue_free()

	panel.modulate.a = 0.0
	var t := panel.create_tween()
	t.tween_property(panel, "modulate:a", 1.0, 0.25)
	t.tween_interval(duration)
	t.tween_property(panel, "modulate:a", 0.0, 0.4)
	t.tween_callback(panel.queue_free)

func notify_problem(description: String, icon := "⚠️") -> void:
	show_toast(description, "Novo problema identificado", icon, DEFAULT_DURATION, "warning")

func notify_concept(concept_name: String) -> void:
	show_toast(concept_name, "📖 Conceito desbloqueado", "", DEFAULT_DURATION + 1.0, "success")

func notify_sms(sender: String, message: String) -> void:
	show_toast(message, sender, "✉️", DEFAULT_DURATION + 2.0, "sms")

## Toast de "registro resolvido": mostra o problema e o ganho de satisfação.
func notify_resolved(problem_label: String, satisfaction_gain: float) -> void:
	var msg := "%s  ·  +%d%% de satisfação" % [problem_label, int(round(satisfaction_gain))]
	show_toast(msg, "Registro resolvido", "✅", DEFAULT_DURATION + 1.0, "success")

## Toast de penalidade: avisa que a satisfação caiu (usado nas escolhas negativas).
func notify_penalty(satisfaction_loss: float, reason := "") -> void:
	var msg := "-%d%% de satisfação" % int(round(satisfaction_loss))
	if reason != "":
		msg = "%s  ·  %s" % [reason, msg]
	show_toast(msg, "Satisfação caiu", "📉", DEFAULT_DURATION, "warning")

func _make_stylebox(accent: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.11, 0.15, 0.96)
	sb.set_corner_radius_all(8)
	sb.set_border_width_all(0)
	sb.border_width_left = 4
	sb.border_color = accent
	sb.content_margin_left = 0
	return sb

# --- Auto-teste opcional (só em build de debug; remover quando ligar no fluxo) ---
func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_N:
		notify_problem("Moradia comprometida após enchente", "🏠")
		show_toast("Mensagem de teste do sistema de notificações.", "Notificação", "📢")
		notify_concept("Aluguel Social")
		notify_sms("Prefeitura / Coordenação", "Ótimo trabalho! Dirija-se ao abrigo na escola.")
