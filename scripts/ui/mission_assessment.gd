extends CanvasLayer
## Avaliacao da missao 1 — duas paginas por spread (esquerda + direita).

const DATA_PATH := "res://scripts/data/mission_01_assessment.gd"
const FONT_PATH := "res://assets/fonts/PatrickHand-Regular.ttf"
const SPREAD_PAGE_DELAY := 3.0

## Calibre o caderno aqui — unico lugar para posicao, linhas e fontes padrao.
## left/right page: offset_left, offset_top, offset_right, offset_bottom
## content_width de cada pagina = right - left (calculado automaticamente)
const LAYOUT := {
	"notebook_size": 820.0,
	"line_height": 38.0,
	"page_separation": 10,
	"option_separation": 2,
	"left_page": {
		"left": 40.0,
		"top": 162.0,
		"right": 379.0,
		"bottom": 770.0,
	},
	"right_page": {
		"left": 568.0,
		"top": 139.0,
		"right": 949.0,
		"bottom": 747.0,
	},
	"fonts": {
		"title": 24,
		"progress": 24,
		"question": 22,
		"option": 21,
		"feedback": 19,
	},
}

const INK := Color(0.02, 0.04, 0.16, 1)
const INK_MUTED := Color(0.12, 0.16, 0.28, 1)
const INK_CORRECT := Color(0.04, 0.32, 0.14, 1)
const INK_WRONG := Color(0.52, 0.08, 0.06, 1)
const INK_HOVER := Color(0.02, 0.1, 0.32, 1)

const FALLBACK_TITLE := "Prova da Missão 1 - A chuva não para"
const FALLBACK_QUESTIONS: Array = [
	{
		"text": "Durante uma enchente, qual órgão orienta a população e indica locais seguros?",
		"options": ["A) COMPESA", "B) Defesa Civil", "C) Procon"],
		"correct_index": 1,
	},
]

@onready var _backdrop: ColorRect = $Backdrop
@onready var _intro_panel: PanelContainer = $IntroPanel
@onready var _quiz_root: Control = $QuizRoot
@onready var _notebook_pivot: Control = $QuizRoot/CenterContainer/NotebookPivot
@onready var _left_page: VBoxContainer = $QuizRoot/CenterContainer/NotebookPivot/LeftPage
@onready var _exam_title: Label = $QuizRoot/CenterContainer/NotebookPivot/LeftPage/ExamTitle
@onready var _progress_label: Label = $QuizRoot/CenterContainer/NotebookPivot/LeftPage/ProgressLabel
@onready var _left_question: Label = $QuizRoot/CenterContainer/NotebookPivot/LeftPage/QuestionLabel
@onready var _left_options: VBoxContainer = $QuizRoot/CenterContainer/NotebookPivot/LeftPage/OptionsContainer
@onready var _left_feedback: Label = $QuizRoot/CenterContainer/NotebookPivot/LeftPage/FeedbackLabel
@onready var _right_page: VBoxContainer = $QuizRoot/CenterContainer/NotebookPivot/RightPage
@onready var _right_question: Label = $QuizRoot/CenterContainer/NotebookPivot/RightPage/QuestionLabel
@onready var _right_options: VBoxContainer = $QuizRoot/CenterContainer/NotebookPivot/RightPage/OptionsContainer
@onready var _right_feedback: Label = $QuizRoot/CenterContainer/NotebookPivot/RightPage/FeedbackLabel

var _title: String = FALLBACK_TITLE
var _questions: Array = FALLBACK_QUESTIONS
var _mission_complete: CanvasLayer
var _spread_start_index := 0
var _score := 0
var _active := false
var _spread_token := 0
var _left_answered := false
var _right_answered := false
var _right_has_question := false
var _notebook_font: Font
var _option_btn_normal: StyleBoxEmpty
var _option_btn_hover: StyleBoxFlat
var _option_btn_pressed: StyleBoxFlat
var _option_btn_disabled: StyleBoxEmpty

func _ready() -> void:
	visible = false
	_intro_panel.hide()
	_quiz_root.hide()
	_left_feedback.hide()
	_right_feedback.hide()
	add_to_group("mission_assessment")
	_notebook_font = load(FONT_PATH) as Font
	_build_option_button_styles()
	_apply_layout()
	_apply_label_styles()
	_load_assessment_data()

func _layout_page(page_key: String) -> Dictionary:
	return LAYOUT[page_key] as Dictionary

func _layout_content_width(page_key: String) -> float:
	var page := _layout_page(page_key)
	return float(page["right"]) - float(page["left"])

func _layout_line_height() -> float:
	return float(LAYOUT["line_height"])

func _layout_font(key: String) -> int:
	return int(LAYOUT["fonts"][key])

func _apply_page_rect(page: VBoxContainer, page_key: String) -> void:
	var rect := _layout_page(page_key)
	page.offset_left = float(rect["left"])
	page.offset_top = float(rect["top"])
	page.offset_right = float(rect["right"])
	page.offset_bottom = float(rect["bottom"])
	page.add_theme_constant_override("separation", int(LAYOUT["page_separation"]))

func _apply_layout() -> void:
	_apply_page_rect(_left_page, "left_page")
	_apply_page_rect(_right_page, "right_page")

	var option_sep := int(LAYOUT["option_separation"])
	_left_options.add_theme_constant_override("separation", option_sep)
	_right_options.add_theme_constant_override("separation", option_sep)

	var left_width := _layout_content_width("left_page")
	var right_width := _layout_content_width("right_page")
	_exam_title.custom_minimum_size.x = left_width
	_progress_label.custom_minimum_size.x = left_width
	_left_question.custom_minimum_size.x = left_width
	_left_feedback.custom_minimum_size.x = left_width
	_right_question.custom_minimum_size.x = right_width
	_right_feedback.custom_minimum_size.x = right_width

	var notebook_size := float(LAYOUT["notebook_size"])
	_notebook_pivot.custom_minimum_size = Vector2(notebook_size, notebook_size)

func _build_option_button_styles() -> void:
	_option_btn_normal = StyleBoxEmpty.new()
	_option_btn_disabled = StyleBoxEmpty.new()
	_option_btn_hover = _make_ink_line_stylebox(Color(0.02, 0.04, 0.1, 0.1), Color(0.02, 0.08, 0.2, 1))
	_option_btn_pressed = _make_ink_line_stylebox(Color(0.02, 0.04, 0.1, 0.16), Color(0.02, 0.06, 0.16, 1))

func _make_ink_line_stylebox(bg: Color, underline: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_width_bottom = 2
	box.border_color = underline
	box.content_margin_left = 2
	box.content_margin_right = 2
	box.content_margin_top = 2
	box.content_margin_bottom = 4
	return box

func _handwriting_with_emoji_font() -> Font:
	var variation := FontVariation.new()
	variation.base_font = _notebook_font
	variation.fallbacks = [EmojiFont.FONT]
	return variation

func _apply_handwriting(node: Control, size: int, color: Color = INK) -> void:
	if _notebook_font:
		node.add_theme_font_override("font", _notebook_font)
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)
	node.add_theme_constant_override("outline_size", 0)
	if node is BaseButton:
		node.add_theme_color_override("font_hover_color", INK_HOVER)
		node.add_theme_color_override("font_pressed_color", INK)
		node.add_theme_color_override("font_disabled_color", color)
		node.add_theme_color_override("font_focus_color", INK_HOVER)

func _apply_feedback_style(label: Label, size: int, color: Color) -> void:
	label.add_theme_font_override("font", _handwriting_with_emoji_font())
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", 0)

func _apply_label_styles() -> void:
	_apply_handwriting(_exam_title, _layout_font("title"), INK)
	_exam_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	_apply_handwriting(_progress_label, _layout_font("progress"), INK_MUTED)

	_apply_handwriting(_left_question, _layout_font("question"), INK)
	_left_question.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	_apply_handwriting(_right_question, _layout_font("question"), INK)
	_right_question.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	_apply_feedback_style(_left_feedback, _layout_font("feedback"), INK_CORRECT)
	_left_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	_apply_feedback_style(_right_feedback, _layout_font("feedback"), INK_CORRECT)
	_right_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

func _question_int(question: Dictionary, key: String, default_value: int) -> int:
	if question.has(key):
		return int(question[key])
	return default_value

func _question_float(question: Dictionary, key: String, default_value: float) -> float:
	if question.has(key):
		return float(question[key])
	return default_value

func _text_block_height(text: String, line_height: float) -> float:
	return line_height * float(text.count("\n") + 1)

func _auto_question_min_height(question: Dictionary) -> float:
	var text := str(question["text"])
	return _layout_line_height() * float(text.count("\n") + 1)

func _format_progress_label(left_index: int, right_index: int) -> String:
	var total := _questions.size()
	if right_index >= 0:
		return "Questões %d e %d de %d" % [left_index + 1, right_index + 1, total]
	return "Questão %d de %d" % [left_index + 1, total]

func _load_assessment_data() -> void:
	var script := load(DATA_PATH) as Script
	if script == null:
		return
	var data: RefCounted = script.new()
	if data.get("TITLE"):
		_title = str(data.TITLE)
	if data.get("QUESTIONS"):
		_questions = data.QUESTIONS

func _get_notebook_fit_scale() -> float:
	var viewport_size := get_viewport().get_visible_rect().size
	var max_height := viewport_size.y * 0.94
	var max_width := viewport_size.x * 0.78
	return minf(max_height, max_width) / float(LAYOUT["notebook_size"])

func begin_quiz(mission_complete_node: CanvasLayer) -> void:
	if _active:
		return

	_active = true
	_mission_complete = mission_complete_node
	_spread_start_index = 0
	_score = 0
	_spread_token = 0

	_intro_panel.hide()
	_quiz_root.show()
	_exam_title.text = _title
	_backdrop.modulate.a = 1.0
	visible = true
	get_tree().paused = true
	GameManager.pause_game()

	var fit_scale := _get_notebook_fit_scale()
	_notebook_pivot.scale = Vector2(fit_scale * 0.92, fit_scale * 0.92)
	_notebook_pivot.modulate.a = 0.0
	_notebook_pivot.rotation = -0.015
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_notebook_pivot, "scale", Vector2(fit_scale, fit_scale), 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_notebook_pivot, "modulate:a", 1.0, 0.35)
	tween.tween_property(_notebook_pivot, "rotation", 0.0, 0.4).set_trans(Tween.TRANS_SINE)

	_show_spread(0)

func _show_spread(start_index: int) -> void:
	_spread_start_index = start_index
	_left_answered = false
	_right_answered = false
	_left_feedback.hide()
	_right_feedback.hide()

	var right_index := start_index + 1
	_right_has_question = right_index < _questions.size()
	_right_page.visible = _right_has_question

	_progress_label.text = _format_progress_label(start_index, right_index if _right_has_question else -1)

	_populate_page(
		start_index,
		_left_question,
		_left_options,
		_left_feedback,
		_layout_content_width("left_page")
	)

	if _right_has_question:
		_populate_page(
			right_index,
			_right_question,
			_right_options,
			_right_feedback,
			_layout_content_width("right_page")
		)
	else:
		_clear_page(_right_question, _right_options, _right_feedback)

func _clear_page(question_label: Label, options_container: VBoxContainer, feedback_label: Label) -> void:
	question_label.text = ""
	feedback_label.hide()
	for child in options_container.get_children():
		child.queue_free()

func _populate_page(
	question_index: int,
	question_label: Label,
	options_container: VBoxContainer,
	feedback_label: Label,
	default_width: float
) -> void:
	feedback_label.hide()
	var question: Dictionary = _questions[question_index]
	var question_width := _question_float(question, "content_width", default_width)
	var question_font_size := _question_int(question, "font_size", _layout_font("question"))
	var question_min_height := _question_float(question, "min_height", _auto_question_min_height(question))
	var option_font_size := _question_int(question, "option_font_size", _layout_font("option"))
	var option_line_height := _question_float(question, "option_line_height", _layout_line_height())

	question_label.custom_minimum_size = Vector2(question_width, question_min_height)
	question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	question_label.text = "%d) %s" % [question_index + 1, question["text"]]
	_apply_handwriting(question_label, question_font_size, INK)

	for child in options_container.get_children():
		child.queue_free()

	var options: Array = question["options"]
	for option_index in range(options.size()):
		var option_text := str(options[option_index])
		var btn := _create_option_button(
			question_index,
			option_index,
			option_text,
			question_width,
			option_font_size,
			option_line_height
		)
		options_container.add_child(btn)

func _create_option_button(
	question_index: int,
	option_index: int,
	option_text: String,
	width: float,
	font_size: int,
	line_height: float
) -> Button:
	var btn := Button.new()
	btn.text = option_text
	btn.flat = true
	btn.process_mode = Node.PROCESS_MODE_ALWAYS
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.custom_minimum_size = Vector2(width, _text_block_height(option_text, line_height))
	btn.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_apply_handwriting(btn, font_size, INK)
	btn.add_theme_stylebox_override("normal", _option_btn_normal)
	btn.add_theme_stylebox_override("hover", _option_btn_hover)
	btn.add_theme_stylebox_override("pressed", _option_btn_pressed)
	btn.add_theme_stylebox_override("disabled", _option_btn_disabled)
	btn.add_theme_stylebox_override("focus", _option_btn_hover)
	btn.pressed.connect(_on_option_selected.bind(question_index, option_index))
	return btn

func _on_option_selected(question_index: int, option_index: int) -> void:
	var is_left := question_index == _spread_start_index
	var is_right := _right_has_question and question_index == _spread_start_index + 1
	if not is_left and not is_right:
		return
	if is_left and _left_answered:
		return
	if is_right and _right_answered:
		return

	var question: Dictionary = _questions[question_index]
	var options_container := _left_options if is_left else _right_options
	var feedback_label := _left_feedback if is_left else _right_feedback
	var option_font_size := _question_int(question, "option_font_size", _layout_font("option"))
	var correct_index := int(question["correct_index"])
	var is_correct: bool = option_index == correct_index

	if is_correct:
		_score += 1
		feedback_label.text = "✅ Correto!"
		_apply_feedback_style(feedback_label, _layout_font("feedback"), INK_CORRECT)
	else:
		var correct_text: String = question["options"][correct_index]
		feedback_label.text = "❌ Errado. Resposta: %s" % correct_text
		_apply_feedback_style(feedback_label, _layout_font("feedback"), INK_WRONG)
	feedback_label.show()

	for i in range(options_container.get_child_count()):
		var btn := options_container.get_child(i) as Button
		if btn == null:
			continue
		btn.disabled = true
		if i == correct_index:
			_apply_handwriting(btn, option_font_size, INK_CORRECT)
		elif i == option_index and not is_correct:
			_apply_handwriting(btn, option_font_size, INK_WRONG)

	if is_left:
		_left_answered = true
	else:
		_right_answered = true

	_try_advance_spread()

func _try_advance_spread() -> void:
	if not _left_answered:
		return
	if _right_has_question and not _right_answered:
		return

	_spread_token += 1
	var token := _spread_token
	await get_tree().create_timer(SPREAD_PAGE_DELAY, true).timeout
	if token != _spread_token or not _active:
		return

	var next_index := _spread_start_index + 2
	if next_index >= _questions.size():
		_finish_assessment()
	else:
		_show_spread(next_index)

func _finish_assessment() -> void:
	var total := _questions.size()
	var fade_out := create_tween()
	fade_out.tween_property(_backdrop, "modulate:a", 0.0, 0.25)
	await fade_out.finished
	_close_assessment()
	GameManager.assessment_completed = true
	if _mission_complete and _mission_complete.has_method("show_mission_complete"):
		_mission_complete.show_mission_complete(_score, total)

func _close_assessment() -> void:
	_active = false
	visible = false
	_quiz_root.hide()
	get_tree().paused = false
	GameManager.resume_game()
