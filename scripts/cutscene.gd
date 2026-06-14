# scripts/cutscene.gd
# Primitivas de cutscene reutilizáveis: fade preto, card de passagem de tempo e
# trava do controle do jogador. NÃO é autoload — chame as funções estáticas:
#   await Cutscene.fade_out()
#   await Cutscene.show_time_card("Alguns dias depois...")
#   await Cutscene.lock_input_for(1.0)
class_name Cutscene
extends RefCounted

const LAYER := 108  # acima do gameplay/HUD/pop-ups, abaixo do MissionComplete (110)

static var _layer: CanvasLayer
static var _overlay: ColorRect

static func _tree() -> SceneTree:
	return Engine.get_main_loop() as SceneTree

static func _ensure_overlay() -> ColorRect:
	if is_instance_valid(_overlay):
		return _overlay
	_layer = CanvasLayer.new()
	_layer.layer = LAYER
	_layer.process_mode = Node.PROCESS_MODE_ALWAYS  # anima mesmo com o jogo pausado
	_tree().root.add_child(_layer)

	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_overlay)
	return _overlay

## Escurece a tela (fade para preto).
static func fade_out(duration := 0.5) -> void:
	var overlay := _ensure_overlay()
	var t := overlay.create_tween()
	t.tween_property(overlay, "color:a", 1.0, duration)
	await t.finished

## Clareia a tela de volta ao jogo.
static func fade_in(duration := 0.5) -> void:
	var overlay := _ensure_overlay()
	var t := overlay.create_tween()
	t.tween_property(overlay, "color:a", 0.0, duration)
	await t.finished

## Passagem de tempo: escurece, mostra um texto central, segura e clareia de volta.
static func show_time_card(text: String, hold := 2.0, fade := 0.6) -> void:
	var overlay := _ensure_overlay()
	var t := overlay.create_tween()
	t.tween_property(overlay, "color:a", 1.0, fade)
	await t.finished

	var label := Label.new()
	label.text = text
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(0.92, 0.94, 0.97))
	label.modulate.a = 0.0
	_layer.add_child(label)

	var t_in := label.create_tween()
	t_in.tween_property(label, "modulate:a", 1.0, 0.4)
	await t_in.finished

	await _tree().create_timer(hold).timeout

	var t_out := label.create_tween()
	t_out.tween_property(label, "modulate:a", 0.0, 0.4)
	await t_out.finished
	label.queue_free()

	var t_clear := overlay.create_tween()
	t_clear.tween_property(overlay, "color:a", 0.0, fade)
	await t_clear.finished

## Congela o controle do jogador.
static func lock_input() -> void:
	_set_input_enabled(false)

## Devolve o controle do jogador.
static func unlock_input() -> void:
	_set_input_enabled(true)

## Congela o controle por X segundos e devolve automaticamente.
static func lock_input_for(seconds: float) -> void:
	lock_input()
	await _tree().create_timer(seconds).timeout
	unlock_input()

static func _set_input_enabled(enabled: bool) -> void:
	for player in Globals.get_players():
		if player is PlayerEntity:
			player.input_enabled = enabled
