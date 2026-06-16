# scripts/ui/phone_menu.gd
extends Control

signal contact_challenge_succeeded

# View Containers
@onready var header_title = $Panel/VBoxContainer/Header/HBox/Title
@onready var back_button = $Panel/VBoxContainer/Header/HBox/BackButton
@onready var close_button = $Panel/VBoxContainer/Header/HBox/CloseButton

@onready var home_view = $Panel/VBoxContainer/ContentView/HomeView
@onready var problems_list_view = $Panel/VBoxContainer/ContentView/ProblemsListView
@onready var problem_detail_view = $Panel/VBoxContainer/ContentView/ProblemDetailView
@onready var indicators_view = $Panel/VBoxContainer/ContentView/IndicatorsView
@onready var concepts_view = $Panel/VBoxContainer/ContentView/ConceptsView
@onready var content_view = $Panel/VBoxContainer/ContentView
@onready var concepts_vbox = $Panel/VBoxContainer/ContentView/ConceptsView/Scroll/VBox
@onready var concept_card_defesa = $Panel/VBoxContainer/ContentView/ConceptsView/Scroll/VBox/MarginContainer3
@onready var concept_card_aluguel = $Panel/VBoxContainer/ContentView/ConceptsView/Scroll/VBox/MarginContainer4

@onready var concepts_aluguel_social_container = $Panel/VBoxContainer/ContentView/ConceptsView/Scroll/VBox/MarginContainer4
@onready var aluguel_social_card = $Panel/VBoxContainer/ContentView/ConceptsView/Scroll/VBox/MarginContainer4/AluguelSocialCard

var aluguel_social_detail_view: Control
var step_title_label: Label
var step_desc_label: Label
var step_icon_label: Label
var step_indicators: Array[PanelContainer] = []
var step_indicator_labels: Array[Label] = []
var current_step_idx: int = 0


# Bottom Navigation Buttons
@onready var nav_home = $Panel/VBoxContainer/BottomNav/HBox/HomeButton
@onready var nav_problems = $Panel/VBoxContainer/BottomNav/HBox/ProblemsButton
@onready var nav_contacts = $Panel/VBoxContainer/BottomNav/HBox/ContactsButton
@onready var nav_indicators = $Panel/VBoxContainer/BottomNav/HBox/IndicatorsButton

# Home Buttons
@onready var home_problems_card = $Panel/VBoxContainer/ContentView/HomeView/Scroll/VBox/ProblemsCard
@onready var home_contacts_card = $Panel/VBoxContainer/ContentView/HomeView/Scroll/VBox/ContactsCard
@onready var home_satisfaction_card = $Panel/VBoxContainer/ContentView/HomeView/Scroll/VBox/SatisfactionCard
@onready var home_concepts_card = $Panel/VBoxContainer/ContentView/HomeView/Scroll/VBox/ConceptsCard

# Problems List Buttons/Cards
@onready var active_tab = $Panel/VBoxContainer/ContentView/ProblemsListView/Scroll/VBox/Tabs/ActiveTab
@onready var completed_tab = $Panel/VBoxContainer/ContentView/ProblemsListView/Scroll/VBox/Tabs/CompletedTab
@onready var problem_card_template = $Panel/VBoxContainer/ContentView/ProblemsListView/Scroll/VBox/WaterProblemCard

# Problem Detail Elements
@onready var detail_icon = $Panel/VBoxContainer/ContentView/ProblemDetailView/VBox/Card/Margin/VBox/HBox/Icon
@onready var detail_title = $Panel/VBoxContainer/ContentView/ProblemDetailView/VBox/Card/Margin/VBox/HBox/Title
@onready var detail_status_tag = $Panel/VBoxContainer/ContentView/ProblemDetailView/VBox/Card/Margin/VBox/HBox/StatusTag
@onready var detail_status_label = $Panel/VBoxContainer/ContentView/ProblemDetailView/VBox/Card/Margin/VBox/HBox/StatusTag/Label
@onready var detail_loc_label = $Panel/VBoxContainer/ContentView/ProblemDetailView/VBox/Card/Margin/VBox/LocLabel
@onready var detail_desc_title = $Panel/VBoxContainer/ContentView/ProblemDetailView/VBox/Card/Margin/VBox/DescTitle
@onready var detail_desc_text = $Panel/VBoxContainer/ContentView/ProblemDetailView/VBox/Card/Margin/VBox/DescText
@onready var detail_impact_title = $Panel/VBoxContainer/ContentView/ProblemDetailView/VBox/Card/Margin/VBox/ImpactTitle
@onready var detail_impact_text = $Panel/VBoxContainer/ContentView/ProblemDetailView/VBox/Card/Margin/VBox/ImpactText
@onready var detail_resolve_button = $Panel/VBoxContainer/ContentView/ProblemDetailView/VBox/MarginContainer/ResolveButton

# Indicators Screen Elements
@onready var ind_saneamento_bar = $Panel/VBoxContainer/ContentView/IndicatorsView/Scroll/VBox/MarginContainer2/VBoxContainer/SaneamentoBar
@onready var ind_satisfacao_bar = $Panel/VBoxContainer/ContentView/IndicatorsView/Scroll/VBox/MarginContainer2/VBoxContainer/SatisfacaoBar
@onready var ind_satisfacao_val = $Panel/VBoxContainer/ContentView/IndicatorsView/Scroll/VBox/MarginContainer2/VBoxContainer/HBoxSatisfacao/Val

const PHONE_TUTORIAL := [
	{
		"title": "Celular",
		"text": "Este é o celular. Aqui você consulta informações públicas e acompanha o que está acontecendo no bairro."
	},
	{
		"title": "Registro de Problemas",
		"text": "No Registro de Problemas você vê ocorrências registradas — como abrigos abertos e outros serviços."
	},
	{
		"title": "Contatos / Responsáveis",
		"text": "Em Contatos você encontra órgãos públicos e telefones úteis, como Defesa Civil e COMPESA."
	},
	{
		"title": "Satisfação da Cidade",
		"text": "A Satisfação mostra como suas ações impactam a qualidade de vida da comunidade."
	},
	{
		"title": "Conceitos e Aprendizados",
		"text": "Em Aprendizados você consulta conceitos sobre direitos, serviços públicos e programas sociais."
	}
]

var current_screen: String = "home"
var active_problem: String = "water"
var selected_quiz_option: int = 0
var phone_glowing: bool = false
var current_problems_tab: String = "active"

var style_active: StyleBox
var style_active_hover: StyleBox
var style_inactive: StyleBox
var style_inactive_hover: StyleBox

var shelter_problem_card: Button
var housing_problem_card: Button
var _tutorial_overlay: ColorRect
var _tutorial_panel: PanelContainer
var _tutorial_title: Label
var _tutorial_desc: Label
var _tutorial_button: Button
var _tutorial_index: int = 0
var _tutorial_completed: bool = false

# Conceitos desbloqueáveis
var _unlocked_concepts := {}
var _concept_nodes := {}
var _concepts_empty_label: Label

# Contatos (lista + modo desafio)
const CONTACTS := [
	{"id": "defesa_civil", "icon": "🛡️", "name": "Defesa Civil", "phone": "199", "role": "Gestão de desastres, mapeamento de áreas de risco, evacuações e socorro a desalojados."},
	{"id": "guarda", "icon": "👮", "name": "Guarda Municipal", "phone": "153", "role": "Segurança patrimonial, mediação de conflitos urbanos e proteção de bens públicos."},
	{"id": "procon", "icon": "⚖️", "name": "PROCON", "phone": "151", "role": "Proteção, orientação e defesa dos direitos do consumidor."},
]
var _contacts_list_view: Control
var _contacts_vbox: VBoxContainer
var _contacts_instruction: Label
var _challenge_active := false
var _challenge_correct_id := ""

func _ready():
	hide()
	_setup_shelter_card()
	_setup_housing_card()
	_build_tutorial_overlay()
	_build_contacts_list()
	_setup_concepts()
	
	style_active = active_tab.get_theme_stylebox("normal")
	style_active_hover = active_tab.get_theme_stylebox("hover")
	style_inactive = completed_tab.get_theme_stylebox("normal")
	style_inactive_hover = completed_tab.get_theme_stylebox("hover")

	back_button.pressed.connect(_on_back_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	active_tab.pressed.connect(func(): _set_problems_tab("active"))
	completed_tab.pressed.connect(func(): _set_problems_tab("completed"))
	
	nav_home.pressed.connect(func(): _show_screen("home"))
	nav_problems.pressed.connect(func(): _show_screen("problems_list"))
	nav_contacts.pressed.connect(func(): _show_screen("contacts_list"))
	nav_indicators.pressed.connect(func(): _show_screen("indicators"))
	
	home_problems_card.pressed.connect(func(): _show_screen("problems_list"))
	home_contacts_card.pressed.connect(func(): _show_screen("contacts_list"))
	home_satisfaction_card.pressed.connect(func(): _show_screen("indicators"))
	home_concepts_card.pressed.connect(func(): _show_screen("concepts"))
	
	GameManager.stage_changed.connect(_on_stage_changed)
	
	_setup_aluguel_social_detail_view()
	if aluguel_social_card:
		aluguel_social_card.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_show_aluguel_social_detail()
		)
	
	_update_phone_ui_state()
	_show_screen("home")

func toggle():
	visible = not visible
	if visible:
		_update_phone_ui_state()
		_show_screen("home")
		if GameManager.current_stage == 4 and not _tutorial_completed:
			_start_phone_tutorial()

func _setup_shelter_card() -> void:
	shelter_problem_card = problem_card_template.duplicate(DUPLICATE_USE_INSTANTIATION) as Button
	problem_card_template.get_parent().add_child(shelter_problem_card)
	shelter_problem_card.name = "ShelterProblemCard"
	
	var icon := shelter_problem_card.get_node("Margin/VBox/HBox/Icon") as Label
	var title := shelter_problem_card.get_node("Margin/VBox/HBox/Title") as Label
	var status_tag := shelter_problem_card.get_node("Margin/VBox/HBox/StatusTag") as PanelContainer
	var status_label := shelter_problem_card.get_node("Margin/VBox/HBox/StatusTag/Label") as Label
	var loc_label := shelter_problem_card.get_node("Margin/VBox/LocLabel") as Label
	var date_label := shelter_problem_card.get_node("Margin/VBox/DateLabel") as Label
	var update_label := shelter_problem_card.get_node("Margin/VBox/UpdateLabel") as Label
	
	icon.text = "🏫"
	title.text = "Abrigo temporário"
	status_tag.self_modulate = Color("2E6B8A")
	status_label.text = "Disponível"
	loc_label.text = "📍 Escola Municipal — 2 quarteirões"
	date_label.text = "📅 Aberto pela Defesa Civil e Prefeitura"
	update_label.text = "Vagas disponíveis para famílias afetadas pela chuva."
	
	shelter_problem_card.pressed.connect(func(): _show_problem_detail("shelter"))

func _setup_housing_card() -> void:
	housing_problem_card = problem_card_template.duplicate(DUPLICATE_USE_INSTANTIATION) as Button
	problem_card_template.get_parent().add_child(housing_problem_card)
	housing_problem_card.name = "HousingProblemCard"
	
	var icon := housing_problem_card.get_node("Margin/VBox/HBox/Icon") as Label
	var title := housing_problem_card.get_node("Margin/VBox/HBox/Title") as Label
	var status_tag := housing_problem_card.get_node("Margin/VBox/HBox/StatusTag") as PanelContainer
	var status_label := housing_problem_card.get_node("Margin/VBox/HBox/StatusTag/Label") as Label
	var loc_label := housing_problem_card.get_node("Margin/VBox/LocLabel") as Label
	var date_label := housing_problem_card.get_node("Margin/VBox/DateLabel") as Label
	var update_label := housing_problem_card.get_node("Margin/VBox/UpdateLabel") as Label
	
	icon.text = "🏠"
	title.text = "Moradia comprometida"
	status_tag.self_modulate = Color("A63F3F")
	status_label.text = "Não Resolvido"
	loc_label.text = "📍 Rua da Dona Maria"
	date_label.text = "📅 Identificado após enchente"
	update_label.text = "Parede rachada e risco estrutural na residência."
	
	housing_problem_card.pressed.connect(func(): _show_problem_detail("housing"))

func _build_tutorial_overlay() -> void:
	_tutorial_overlay = ColorRect.new()
	_tutorial_overlay.name = "TutorialOverlay"
	_tutorial_overlay.color = Color(0, 0, 0, 0.72)
	_tutorial_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tutorial_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_tutorial_overlay.hide()
	add_child(_tutorial_overlay)
	
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tutorial_overlay.add_child(center)
	
	_tutorial_panel = PanelContainer.new()
	_tutorial_panel.custom_minimum_size = Vector2(520, 0)
	center.add_child(_tutorial_panel)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	_tutorial_panel.add_child(margin)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)
	
	_tutorial_title = Label.new()
	_tutorial_title.add_theme_font_size_override("font_size", 22)
	_tutorial_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_tutorial_title)
	
	_tutorial_desc = Label.new()
	_tutorial_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_tutorial_desc)
	
	_tutorial_button = Button.new()
	_tutorial_button.text = "Próximo"
	_tutorial_button.custom_minimum_size = Vector2(0, 44)
	_tutorial_button.pressed.connect(_on_tutorial_next_pressed)
	vbox.add_child(_tutorial_button)

func _start_phone_tutorial() -> void:
	_tutorial_index = 0
	GameManager.pause_game()
	_tutorial_overlay.show()
	_update_tutorial_step()

func _update_tutorial_step() -> void:
	var step: Dictionary = PHONE_TUTORIAL[_tutorial_index]
	_tutorial_title.text = step["title"]
	_tutorial_desc.text = step["text"]
	var is_last := _tutorial_index >= PHONE_TUTORIAL.size() - 1
	_tutorial_button.text = "Entendi" if is_last else "Próximo"

func _on_tutorial_next_pressed() -> void:
	if _tutorial_index < PHONE_TUTORIAL.size() - 1:
		_tutorial_index += 1
		_update_tutorial_step()
		return
	
	_tutorial_overlay.hide()
	_tutorial_completed = true
	GameManager.resume_game()
	if GameManager.current_stage == 4:
		print("[PhoneMenu] Phone tutorial completed, advancing to stage 5...")
		GameManager.advance_stage()

func _show_problem_detail(problem_id: String) -> void:
	active_problem = problem_id
	if problem_id == "shelter":
		detail_icon.text = "🏫"
		detail_title.text = "Abrigo temporário"
		if GameManager.current_stage >= 8:
			detail_status_tag.self_modulate = Color("4E8C50")
			detail_status_label.text = " Concluído "
		else:
			detail_status_tag.self_modulate = Color("2E6B8A")
			detail_status_label.text = " Disponível "
		detail_loc_label.text = "📍 Escola Municipal — esquina da rua, 2 quarteirões"
		detail_desc_title.text = "Informações:"
		detail_desc_text.text = "Abrigo emergencial aberto pela Prefeitura do Recife e Defesa Civil para famílias afetadas pelas chuvas. O local oferece colchões, água e apoio de assistentes sociais."
		detail_impact_title.text = "Como chegar:"
		detail_impact_text.text = "📍 Siga a seta indicativa na tela até a escola. A entrada fica na lateral do prédio."
		detail_resolve_button.hide()
	elif problem_id == "housing":
		detail_icon.text = "🏠"
		detail_title.text = "Moradia comprometida"
		detail_status_tag.self_modulate = Color("4E8C50") if GameManager.housing_solved else Color("A63F3F")
		detail_status_label.text = " Resolvido " if GameManager.housing_solved else " Não resolvido "
		detail_loc_label.text = "📍 Rua da Dona Maria"
		detail_desc_title.text = "Resumo da situação:"
		detail_desc_text.text = "A residência de Dona Maria ficou com paredes rachadas e piso levantado após a enchente, gerando risco estrutural e perigo de desabamento."
		detail_impact_title.text = "Impacto:"
		detail_impact_text.text = "Família desabrigada e com medo de retornar para casa sem auxílio ou moradia segura."
		detail_resolve_button.hide() # Resolvida automaticamente por diálogo/pergunta na rua
	_show_screen("problem_detail")
	if problem_id == "shelter" and GameManager.current_stage == 5:
		print("[PhoneMenu] Shelter located in registry, advancing to stage 6...")
		GameManager.advance_stage()

func _show_screen(screen_name: String):
	var previous_screen = current_screen
	current_screen = screen_name
	
	# Prepare for transition
	var target_view: Control = null
	match screen_name:
		"home": target_view = home_view
		"problems_list": target_view = problems_list_view
		"problem_detail": target_view = problem_detail_view
		"contacts_list": target_view = _contacts_list_view
		"indicators": target_view = indicators_view
		"concepts": target_view = concepts_view

	# Hide all views (instantly for now, or fade out if you want)
	for view in [home_view, problems_list_view, problem_detail_view, indicators_view, concepts_view]:
		if view: view.hide()
	if _contacts_list_view: _contacts_list_view.hide()

	# Update Headers
	if aluguel_social_detail_view:
		aluguel_social_detail_view.hide()

	if target_view:
		target_view.show()
		target_view.modulate.a = 0
		var tween = create_tween()
		tween.tween_property(target_view, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_SINE)
		
		# Small scale pop for effect
		target_view.scale = Vector2(0.98, 0.98)
		tween.parallel().tween_property(target_view, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	match screen_name:
		"home":
			header_title.text = "GESTÃO DA CIDADE"
			back_button.hide()
		"problems_list":
			header_title.text = "REGISTROS"
			back_button.show()
		"problem_detail":
			header_title.text = "REGISTROS"
			back_button.show()
		"contacts_list":
			header_title.text = "CONTATOS"
			back_button.show()
		"indicators":
			header_title.text = "SATISFAÇÃO"
			back_button.show()
			_update_indicators_screen()
		"concepts":
			header_title.text = "APRENDIZADOS"
			back_button.show()
		"aluguel_social_detail":
			if aluguel_social_detail_view:
				aluguel_social_detail_view.show()
			header_title.text = "ALUGUEL SOCIAL"
			back_button.show()
			
	_update_nav_highlight()
	_update_phone_ui_state()

func _update_nav_highlight():
	# Define active and inactive colors
	var active_color = Color(0.1, 0.37, 0.39) # Teal
	var inactive_color = Color(0.6, 0.6, 0.6) # Gray
	
	nav_home.add_theme_color_override("font_color", active_color if current_screen == "home" else inactive_color)
	nav_problems.add_theme_color_override("font_color", active_color if current_screen in ["problems_list", "problem_detail"] else inactive_color)
	nav_contacts.add_theme_color_override("font_color", active_color if current_screen == "contacts_list" else inactive_color)
	nav_indicators.add_theme_color_override("font_color", active_color if current_screen == "indicators" else inactive_color)

func _on_back_pressed():
	match current_screen:
		"problems_list", "indicators", "concepts", "contacts_list":
			_show_screen("home")
		"aluguel_social_detail":
			_show_screen("concepts")
		"problem_detail":
			_show_screen("problems_list")

func _on_close_pressed():
	if _tutorial_overlay.visible:
		return
	hide()

func _update_phone_ui_state():
	var phone_unlocked := GameManager.current_stage >= 4
	
	if concepts_aluguel_social_container:
		concepts_aluguel_social_container.visible = GameManager.housing_solved or GameManager.current_stage >= 10
	
	if not phone_unlocked:
		problem_card_template.hide()
		if shelter_problem_card:
			shelter_problem_card.hide()
		if housing_problem_card:
			housing_problem_card.hide()
		home_problems_card.disabled = true
		home_contacts_card.disabled = true
		nav_problems.disabled = true
		nav_contacts.disabled = true
	else:
		problem_card_template.hide()
		
		if current_problems_tab == "active":
			if shelter_problem_card:
				if GameManager.current_stage < 8:
					shelter_problem_card.show()
				else:
					shelter_problem_card.hide()
			if housing_problem_card:
				if GameManager.current_stage >= 9 and not GameManager.housing_solved:
					housing_problem_card.show()
				else:
					housing_problem_card.hide()
		else:
			if shelter_problem_card:
				if GameManager.current_stage >= 8:
					shelter_problem_card.show()
				else:
					shelter_problem_card.hide()
			if housing_problem_card:
				if GameManager.current_stage >= 9 and GameManager.housing_solved:
					housing_problem_card.show()
				else:
					housing_problem_card.hide()

		home_problems_card.disabled = false
		home_contacts_card.disabled = false
		nav_problems.disabled = false
		nav_contacts.disabled = false

	if housing_problem_card:
		var status_tag := housing_problem_card.get_node("Margin/VBox/HBox/StatusTag") as PanelContainer
		var status_label := housing_problem_card.get_node("Margin/VBox/HBox/StatusTag/Label") as Label
		var update_label := housing_problem_card.get_node("Margin/VBox/UpdateLabel") as Label
		
		if GameManager.housing_solved:
			status_tag.self_modulate = Color("4E8C50")
			status_label.text = "Resolvido"
			update_label.text = "Última atualização: Encaminhado para o Aluguel Social."
		else:
			status_tag.self_modulate = Color("A63F3F")
			status_label.text = "Não resolvido"
			update_label.text = "Última atualização: Moradia estruturalmente comprometida."

	if shelter_problem_card:
		var status_tag := shelter_problem_card.get_node("Margin/VBox/HBox/StatusTag") as PanelContainer
		var status_label := shelter_problem_card.get_node("Margin/VBox/HBox/StatusTag/Label") as Label
		var update_label := shelter_problem_card.get_node("Margin/VBox/UpdateLabel") as Label
		
		if GameManager.current_stage >= 8:
			status_tag.self_modulate = Color("4E8C50")
			status_label.text = "Concluído"
			update_label.text = "Última atualização: Visita ao abrigo concluída."
		else:
			status_tag.self_modulate = Color("2E6B8A")
			status_label.text = "Disponível"
			update_label.text = "Vagas disponíveis para famílias afetadas pela chuva."

func _update_indicators_screen():
	ind_satisfacao_bar.value = GameManager.satisfaction
	ind_satisfacao_val.text = "%d%%" % int(GameManager.satisfaction)
	ind_saneamento_bar.value = 50.0

func _on_stage_changed(new_stage: int):
	if new_stage == 4:
		phone_glowing = true
		print("[PhoneMenu] Phone is glowing! Player needs to open phone.")
	if new_stage >= 4:
		_ensure_base_concepts()

# --- Conceitos desbloqueáveis ---

func _setup_concepts() -> void:
	_concept_nodes = {
		"defesa_civil": {"node": concept_card_defesa, "title": "Defesa Civil"},
		"aluguel_social": {"node": concept_card_aluguel, "title": "Aluguel Social"},
	}

	_concepts_empty_label = Label.new()
	_concepts_empty_label.text = "Nenhum conceito desbloqueado ainda.\nExplore a cidade e converse com as pessoas."
	_concepts_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_concepts_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_concepts_empty_label.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
	concepts_vbox.add_child(_concepts_empty_label)

	_ensure_base_concepts()
	_refresh_concepts_view()

## Libera um conceito pelo id ("defesa_civil", "aluguel_social").
## Mostra um toast de "Conceito desbloqueado" (a menos que silent = true).
func unlock_concept(concept_id: String, silent := false) -> void:
	if not _concept_nodes.has(concept_id) or _unlocked_concepts.has(concept_id):
		return
	_unlocked_concepts[concept_id] = true
	_refresh_concepts_view()
	if not silent:
		Notifications.notify_concept(_concept_nodes[concept_id]["title"])

## Conceitos básicos ficam disponíveis assim que o celular é destravado (stage >= 4).
func _ensure_base_concepts() -> void:
	if GameManager.current_stage >= 4:
		unlock_concept("defesa_civil", true)

func _refresh_concepts_view() -> void:
	for concept_id in _concept_nodes:
		_concept_nodes[concept_id]["node"].visible = _unlocked_concepts.has(concept_id)
	if _concepts_empty_label:
		_concepts_empty_label.visible = _unlocked_concepts.is_empty()

# --- Contatos (lista + modo desafio) ---

func _build_contacts_list() -> void:
	_contacts_list_view = Control.new()
	_contacts_list_view.name = "ContactsListView"
	_contacts_list_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	_contacts_list_view.hide()
	content_view.add_child(_contacts_list_view)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_contacts_list_view.add_child(scroll)

	_contacts_vbox = VBoxContainer.new()
	_contacts_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_contacts_vbox.add_theme_constant_override("separation", 12)
	scroll.add_child(_contacts_vbox)

	var top_spacer := Control.new()
	top_spacer.custom_minimum_size = Vector2(0, 12)
	_contacts_vbox.add_child(top_spacer)

	_contacts_instruction = Label.new()
	_contacts_instruction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_contacts_instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_contacts_instruction.add_theme_color_override("font_color", Color(0.1, 0.37, 0.39)) # Teal dark
	_contacts_instruction.add_theme_font_size_override("font_size", 16)
	_contacts_instruction.hide()
	_contacts_vbox.add_child(_contacts_instruction)

	# Reutiliza os estilos de cartão de um botão que já existe na cena
	# (sem load() da própria cena, que causaria dependência cíclica e impediria
	# o editor de abrir o phone_menu.tscn).
	var card_style : StyleBox = home_problems_card.get_theme_stylebox("normal")
	var hover_style : StyleBox = home_problems_card.get_theme_stylebox("hover")

	for c in CONTACTS:
		var card := Button.new()
		card.custom_minimum_size = Vector2(0, 80)
		card.add_theme_stylebox_override("normal", card_style)
		card.add_theme_stylebox_override("hover", hover_style)
		card.add_theme_stylebox_override("pressed", card_style)
		
		var margin := MarginContainer.new()
		margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin.add_theme_constant_override("margin_left", 16)
		margin.add_theme_constant_override("margin_right", 16)
		card.add_child(margin)
		
		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 14)
		hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin.add_child(hbox)
		
		var icon := Label.new()
		icon.text = c["icon"]
		icon.add_theme_font_size_override("font_size", 28)
		hbox.add_child(icon)
		
		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.alignment = VBoxContainer.ALIGNMENT_CENTER
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hbox.add_child(vbox)
		
		var name_label := Label.new()
		name_label.text = c["name"]
		name_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
		name_label.add_theme_font_size_override("font_size", 18)
		vbox.add_child(name_label)
		
		var phone_label := Label.new()
		phone_label.text = c["phone"]
		phone_label.add_theme_color_override("font_color", Color(0.1, 0.37, 0.39))
		phone_label.add_theme_font_size_override("font_size", 16)
		vbox.add_child(phone_label)
		
		card.pressed.connect(_on_contact_selected.bind(c["id"]))
		_contacts_vbox.add_child(card)

func _get_contact(contact_id: String) -> Dictionary:
	for c in CONTACTS:
		if c["id"] == contact_id:
			return c
	return {}

func _on_contact_selected(contact_id: String) -> void:
	if _challenge_active:
		var c := _get_contact(contact_id)
		if contact_id == _challenge_correct_id:
			_challenge_active = false
			_contacts_instruction.hide()
			await Popups.show_alert(
				"Chamada efetuada com sucesso! A equipe de resgate e transporte adaptado foi acionada.",
				"Fechar",
				"✅ %s" % c["name"]
			)
			contact_challenge_succeeded.emit()
		else:
			await Popups.show_alert(_challenge_feedback(contact_id), "Tentar de novo", "❌ Contato incorreto")
		return

	var c := _get_contact(contact_id)
	await Popups.show_alert("%s\n\n📞 %s" % [c["role"], c["phone"]], "Fechar", "%s %s" % [c["icon"], c["name"]])

func _challenge_feedback(contact_id: String) -> String:
	match contact_id:
		"guarda":
			return "A Guarda Municipal protege o patrimônio e faz mediação urbana, não resgates climáticos."
		"procon":
			return "O PROCON cuida dos direitos do consumidor, não de calamidades."
		_:
			return "Esse não é o contato certo para esta situação."

## Abre o menu de Contatos em modo desafio: o jogador precisa escolher o órgão
## correto. Ao acertar, emite `contact_challenge_succeeded`. (Plano 2, §7)
func start_contact_challenge(correct_id := "defesa_civil", instruction := "") -> void:
	_challenge_active = true
	_challenge_correct_id = correct_id
	if instruction != "":
		_contacts_instruction.text = instruction
	else:
		_contacts_instruction.text = "Qual órgão você deve acionar para o resgate e a evacuação?"
	_contacts_instruction.show()
	if not visible:
		show()
	_show_screen("contacts_list")

func _setup_aluguel_social_detail_view():
	aluguel_social_detail_view = Control.new()
	aluguel_social_detail_view.name = "AluguelSocialDetailView"
	aluguel_social_detail_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	aluguel_social_detail_view.hide()
	$Panel/VBoxContainer/ContentView.add_child(aluguel_social_detail_view)
	
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	aluguel_social_detail_view.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)
	
	var subtitle = Label.new()
	subtitle.text = "Entenda o benefício passo a passo:"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", Color("8E8E8E"))
	vbox.add_child(subtitle)
	
	var steps_hbox = HBoxContainer.new()
	steps_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	steps_hbox.add_theme_constant_override("separation", 15)
	vbox.add_child(steps_hbox)
	
	for i in range(4):
		var step_circle = PanelContainer.new()
		step_circle.custom_minimum_size = Vector2(32, 32)
		step_circle.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var style = StyleBoxFlat.new()
		style.corner_radius_top_left = 16
		style.corner_radius_top_right = 16
		style.corner_radius_bottom_right = 16
		style.corner_radius_bottom_left = 16
		style.bg_color = Color("2E6B8A") if i == 0 else Color("404040")
		step_circle.add_theme_stylebox_override("panel", style)
		
		var num_label = Label.new()
		num_label.text = str(i + 1)
		num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		num_label.add_theme_font_size_override("font_size", 13)
		step_circle.add_child(num_label)
		
		steps_hbox.add_child(step_circle)
		step_indicators.append(step_circle)
		step_indicator_labels.append(num_label)
		
		step_circle.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_set_active_step(i)
		)
	
	var detail_card = PanelContainer.new()
	detail_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color("1A2421")
	card_style.border_width_left = 2
	card_style.border_width_top = 2
	card_style.border_width_right = 2
	card_style.border_width_bottom = 2
	card_style.border_color = Color("2E6B8A")
	card_style.corner_radius_top_left = 12
	card_style.corner_radius_top_right = 12
	card_style.corner_radius_bottom_right = 12
	card_style.corner_radius_bottom_left = 12
	detail_card.add_theme_stylebox_override("panel", card_style)
	vbox.add_child(detail_card)
	
	var card_margin = MarginContainer.new()
	card_margin.add_theme_constant_override("margin_left", 15)
	card_margin.add_theme_constant_override("margin_right", 15)
	card_margin.add_theme_constant_override("margin_top", 15)
	card_margin.add_theme_constant_override("margin_bottom", 15)
	detail_card.add_child(card_margin)
	
	var card_vbox = VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 10)
	card_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card_margin.add_child(card_vbox)
	
	step_icon_label = Label.new()
	step_icon_label.text = "🤝"
	step_icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	step_icon_label.add_theme_font_size_override("font_size", 42)
	card_vbox.add_child(step_icon_label)
	
	step_title_label = Label.new()
	step_title_label.text = "1. Assistência Social"
	step_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	step_title_label.add_theme_font_size_override("font_size", 15)
	step_title_label.add_theme_color_override("font_color", Color("F4F1DE"))
	card_vbox.add_child(step_title_label)
	
	step_desc_label = Label.new()
	step_desc_label.text = ""
	step_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	step_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	step_desc_label.add_theme_font_size_override("font_size", 12)
	step_desc_label.add_theme_color_override("font_color", Color("D0D0D0"))
	card_vbox.add_child(step_desc_label)
	
	var btn_hbox = HBoxContainer.new()
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_hbox)
	
	var prev_btn = Button.new()
	prev_btn.name = "PrevButton"
	prev_btn.text = "Anterior"
	prev_btn.custom_minimum_size = Vector2(90, 36)
	prev_btn.pressed.connect(func():
		if current_step_idx > 0:
			_set_active_step(current_step_idx - 1)
	)
	btn_hbox.add_child(prev_btn)
	
	var next_btn = Button.new()
	next_btn.name = "NextButton"
	next_btn.text = "Próximo"
	next_btn.custom_minimum_size = Vector2(90, 36)
	next_btn.pressed.connect(func():
		if current_step_idx < 3:
			_set_active_step(current_step_idx + 1)
		else:
			_on_aluguel_social_read_finished()
	)
	btn_hbox.add_child(next_btn)

func _show_aluguel_social_detail():
	_show_screen("aluguel_social_detail")
	_set_active_step(0)

func _set_active_step(idx: int):
	current_step_idx = idx
	var step_data = [
		{
			"title": "1. Assistência Social",
			"desc": "O cidadão procura o CRAS (Centro de Referência de Assistência Social) para relatar a situação e receber o primeiro atendimento das equipes de assistência social.",
			"icon": "🤝"
		},
		{
			"title": "2. Cadastro",
			"desc": "É realizado o cadastramento da família no banco de dados de habitação e programas sociais do município, coletando documentos e comprovantes.",
			"icon": "📝"
		},
		{
			"title": "3. Vistoria Técnica",
			"desc": "Profissionais da Defesa Civil e engenheiros vistoriam a residência danificada para atestar o risco estrutural e emitir o laudo oficial de interdição.",
			"icon": "🔎"
		},
		{
			"title": "4. Encaminhamento",
			"desc": "Com o laudo técnico aprovado, a família é encaminhada para receber a liberação do auxílio financeiro mensal para alugar uma moradia provisória segura.",
			"icon": "🔑"
		}
	]
	
	var step = step_data[idx]
	if step_title_label:
		step_title_label.text = step["title"]
	if step_desc_label:
		step_desc_label.text = step["desc"]
	if step_icon_label:
		step_icon_label.text = step["icon"]
		
	for i in range(step_indicators.size()):
		var indicator = step_indicators[i]
		var style = indicator.get_theme_stylebox("panel") as StyleBoxFlat
		if style:
			style = style.duplicate() as StyleBoxFlat
			if i == idx:
				style.bg_color = Color("2E6B8A")
				style.border_color = Color("E07A5F")
				style.border_width_left = 2
				style.border_width_top = 2
				style.border_width_right = 2
				style.border_width_bottom = 2
			elif i < idx:
				style.bg_color = Color("4E8C50")
				style.border_width_left = 0
				style.border_width_top = 0
				style.border_width_right = 0
				style.border_width_bottom = 0
			else:
				style.bg_color = Color("404040")
				style.border_width_left = 0
				style.border_width_top = 0
				style.border_width_right = 0
				style.border_width_bottom = 0
			indicator.add_theme_stylebox_override("panel", style)
			
	var next_btn = aluguel_social_detail_view.find_child("NextButton", true, false) as Button
	if next_btn:
		if idx == 3:
			next_btn.text = "Concluir"
		else:
			next_btn.text = "Próximo"

func _on_aluguel_social_read_finished():
	hide()
	if GameManager.current_stage == 10:
		GameManager.advance_stage()
		print("[PhoneMenu] Concept read complete, advancing to Stage 11: Final da Missão")


func _set_problems_tab(tab_name: String):
	current_problems_tab = tab_name
	
	if tab_name == "active":
		active_tab.add_theme_stylebox_override("normal", style_active)
		active_tab.add_theme_stylebox_override("hover", style_active_hover)
		active_tab.add_theme_stylebox_override("pressed", style_active)
		active_tab.add_theme_stylebox_override("focus", style_active)
		active_tab.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		
		completed_tab.add_theme_stylebox_override("normal", style_inactive)
		completed_tab.add_theme_stylebox_override("hover", style_inactive_hover)
		completed_tab.add_theme_stylebox_override("pressed", style_inactive)
		completed_tab.add_theme_stylebox_override("focus", style_inactive)
		completed_tab.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4, 1))
	else:
		active_tab.add_theme_stylebox_override("normal", style_inactive)
		active_tab.add_theme_stylebox_override("hover", style_inactive_hover)
		active_tab.add_theme_stylebox_override("pressed", style_inactive)
		active_tab.add_theme_stylebox_override("focus", style_inactive)
		active_tab.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4, 1))
		
		completed_tab.add_theme_stylebox_override("normal", style_active)
		completed_tab.add_theme_stylebox_override("hover", style_active_hover)
		completed_tab.add_theme_stylebox_override("pressed", style_active)
		completed_tab.add_theme_stylebox_override("focus", style_active)
		completed_tab.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		
	_update_phone_ui_state()
