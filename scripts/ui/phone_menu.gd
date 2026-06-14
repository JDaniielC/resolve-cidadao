# scripts/ui/phone_menu.gd
extends Control

# View Containers
@onready var header_title = $Panel/VBoxContainer/Header/HBox/Title
@onready var back_button = $Panel/VBoxContainer/Header/HBox/BackButton
@onready var close_button = $Panel/VBoxContainer/Header/HBox/CloseButton

@onready var home_view = $Panel/VBoxContainer/ContentView/HomeView
@onready var problems_list_view = $Panel/VBoxContainer/ContentView/ProblemsListView
@onready var problem_detail_view = $Panel/VBoxContainer/ContentView/ProblemDetailView
@onready var quiz_view = $Panel/VBoxContainer/ContentView/QuizView
@onready var compesa_view = $Panel/VBoxContainer/ContentView/CompesaView
@onready var calling_view = $Panel/VBoxContainer/ContentView/CallingView
@onready var indicators_view = $Panel/VBoxContainer/ContentView/IndicatorsView
@onready var concepts_view = $Panel/VBoxContainer/ContentView/ConceptsView

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
@onready var water_problem_card = $Panel/VBoxContainer/ContentView/ProblemsListView/Scroll/VBox/WaterProblemCard
@onready var water_status_tag = $Panel/VBoxContainer/ContentView/ProblemsListView/Scroll/VBox/WaterProblemCard/Margin/VBox/HBox/StatusTag
@onready var water_status_label = $Panel/VBoxContainer/ContentView/ProblemsListView/Scroll/VBox/WaterProblemCard/Margin/VBox/HBox/StatusTag/Label
@onready var water_update_label = $Panel/VBoxContainer/ContentView/ProblemsListView/Scroll/VBox/WaterProblemCard/Margin/VBox/UpdateLabel

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

# Quiz Elements
@onready var opt_prefeitura = $Panel/VBoxContainer/ContentView/QuizView/VBox/Options/PrefeituraOption
@onready var opt_compesa = $Panel/VBoxContainer/ContentView/QuizView/VBox/Options/CompesaOption
@onready var opt_arpe = $Panel/VBoxContainer/ContentView/QuizView/VBox/Options/ArpeOption
@onready var confirm_quiz_button = $Panel/VBoxContainer/ContentView/QuizView/VBox/MarginContainer/ConfirmButton
@onready var feedback_overlay = $Panel/VBoxContainer/ContentView/QuizView/FeedbackOverlay
@onready var feedback_title = $Panel/VBoxContainer/ContentView/QuizView/FeedbackOverlay/Panel/VBox/Title
@onready var feedback_desc = $Panel/VBoxContainer/ContentView/QuizView/FeedbackOverlay/Panel/VBox/Description
@onready var feedback_ok_button = $Panel/VBoxContainer/ContentView/QuizView/FeedbackOverlay/Panel/VBox/OkButton

# Contact COMPESA Elements
@onready var compesa_call_button = $Panel/VBoxContainer/ContentView/CompesaView/VBox/MarginContainer/CallButton

# Calling Screen Elements
@onready var calling_status = $Panel/VBoxContainer/ContentView/CallingView/VBox/StatusLabel
@onready var calling_desc = $Panel/VBoxContainer/ContentView/CallingView/VBox/DescLabel
@onready var calling_ok_button = $Panel/VBoxContainer/ContentView/CallingView/VBox/OkButton

# Indicators Screen Elements
@onready var ind_saneamento_bar = $Panel/VBoxContainer/ContentView/IndicatorsView/Scroll/VBox/MarginContainer2/VBoxContainer/SaneamentoBar
@onready var ind_satisfacao_bar = $Panel/VBoxContainer/ContentView/IndicatorsView/Scroll/VBox/MarginContainer2/VBoxContainer/SatisfacaoBar
@onready var ind_satisfacao_val = $Panel/VBoxContainer/ContentView/IndicatorsView/Scroll/VBox/MarginContainer2/VBoxContainer/HBoxSatisfacao/Val

const PHONE_TUTORIAL := [
	{
		"title": "Celular da Cidade",
		"text": "Este é o celular da cidade. Aqui você consulta informações públicas e acompanha o que está acontecendo no bairro."
	},
	{
		"title": "Registro de Problemas",
		"text": "No Registro de Problemas você vê ocorrências registradas — como abrigos abertos, falta de água e outros serviços."
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

var shelter_problem_card: Button
var housing_problem_card: Button
var _tutorial_overlay: ColorRect
var _tutorial_panel: PanelContainer
var _tutorial_title: Label
var _tutorial_desc: Label
var _tutorial_button: Button
var _tutorial_index: int = 0
var _tutorial_completed: bool = false

func _ready():
	hide()
	_setup_shelter_card()
	_setup_housing_card()
	_build_tutorial_overlay()
	
	back_button.pressed.connect(_on_back_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	nav_home.pressed.connect(func(): _show_screen("home"))
	nav_problems.pressed.connect(func(): _show_screen("problems_list"))
	nav_contacts.pressed.connect(func(): _show_screen("compesa"))
	nav_indicators.pressed.connect(func(): _show_screen("indicators"))
	
	home_problems_card.pressed.connect(func(): _show_screen("problems_list"))
	home_contacts_card.pressed.connect(func(): _show_screen("compesa"))
	home_satisfaction_card.pressed.connect(func(): _show_screen("indicators"))
	home_concepts_card.pressed.connect(func(): _show_screen("concepts"))
	
	water_problem_card.pressed.connect(func(): _show_problem_detail("water"))
	
	detail_resolve_button.pressed.connect(func(): _show_screen("quiz"))
	
	opt_prefeitura.pressed.connect(func(): _select_quiz_option(1))
	opt_compesa.pressed.connect(func(): _select_quiz_option(2))
	opt_arpe.pressed.connect(func(): _select_quiz_option(3))
	confirm_quiz_button.pressed.connect(_on_confirm_quiz_pressed)
	feedback_ok_button.pressed.connect(_on_feedback_ok_pressed)
	
	compesa_call_button.pressed.connect(_on_call_compesa_pressed)
	calling_ok_button.pressed.connect(_on_calling_ok_pressed)
	
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
	shelter_problem_card = water_problem_card.duplicate(DUPLICATE_USE_INSTANTIATION) as Button
	water_problem_card.get_parent().add_child(shelter_problem_card)
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
	housing_problem_card = water_problem_card.duplicate(DUPLICATE_USE_INSTANTIATION) as Button
	water_problem_card.get_parent().add_child(housing_problem_card)
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
		detail_status_tag.self_modulate = Color("2E6B8A")
		detail_status_label.text = " Disponível "
		detail_loc_label.text = "📍 Escola Municipal — esquina da rua, 2 quarteirões"
		detail_desc_title.text = "Informações:"
		detail_desc_text.text = "Abrigo emergencial aberto pela Prefeitura do Recife e Defesa Civil para famílias afetadas pelas chuvas. O local oferece colchões, água e apoio de assistentes sociais."
		detail_impact_title.text = "Como chegar:"
		detail_impact_text.text = "📍 Siga em direção à escola marcada no mapa da rua. A entrada fica na lateral do prédio."
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
	else:
		_apply_water_detail_view()
	_show_screen("problem_detail")
	if problem_id == "shelter" and GameManager.current_stage == 5:
		print("[PhoneMenu] Shelter located in registry, advancing to stage 6...")
		GameManager.advance_stage()

func _apply_water_detail_view() -> void:
	detail_icon.text = "💧"
	detail_title.text = "Falta de água"
	detail_desc_title.text = "Resumo da queixa:"
	detail_desc_text.text = "Moradores relatam que a água falta vários dias durante a semana. Quando volta, é por pouco tempo e com pouca pressão."
	detail_impact_title.text = "Impacto na satisfação:"
	detail_impact_text.text = "☹️ -10% de satisfação da cidade"
	detail_resolve_button.show()
	_update_phone_ui_state()

func _show_screen(screen_name: String):
	current_screen = screen_name
	
	home_view.hide()
	problems_list_view.hide()
	problem_detail_view.hide()
	quiz_view.hide()
	compesa_view.hide()
	calling_view.hide()
	indicators_view.hide()
	concepts_view.hide()
	feedback_overlay.hide()
	if aluguel_social_detail_view:
		aluguel_social_detail_view.hide()
	
	match screen_name:
		"home":
			home_view.show()
			header_title.text = "GESTÃO DA CIDADE"
			back_button.hide()
		"problems_list":
			problems_list_view.show()
			header_title.text = "REGISTROS"
			back_button.show()
		"problem_detail":
			problem_detail_view.show()
			header_title.text = "REGISTROS"
			back_button.show()
		"quiz":
			quiz_view.show()
			header_title.text = "RESPONSÁVEIS"
			back_button.show()
			_select_quiz_option(0)
		"compesa":
			compesa_view.show()
			header_title.text = "CONTATO"
			back_button.show()
		"calling":
			calling_view.show()
			header_title.text = "LIGANDO..."
			back_button.hide()
		"indicators":
			indicators_view.show()
			header_title.text = "SATISFAÇÃO"
			back_button.show()
			_update_indicators_screen()
		"concepts":
			concepts_view.show()
			header_title.text = "APRENDIZADOS"
			back_button.show()
		"aluguel_social_detail":
			if aluguel_social_detail_view:
				aluguel_social_detail_view.show()
			header_title.text = "ALUGUEL SOCIAL"
			back_button.show()
			
	_update_phone_ui_state()

func _on_back_pressed():
	match current_screen:
		"problems_list", "indicators", "concepts":
			_show_screen("home")
		"aluguel_social_detail":
			_show_screen("concepts")
		"problem_detail":
			_show_screen("problems_list")
		"quiz":
			_show_screen("problem_detail")
		"compesa":
			_show_screen("home")

func _on_close_pressed():
	if _tutorial_overlay.visible:
		return
	hide()

func _select_quiz_option(option_idx: int):
	selected_quiz_option = option_idx
	
	opt_prefeitura.modulate = Color.WHITE
	opt_compesa.modulate = Color.WHITE
	opt_arpe.modulate = Color.WHITE
	
	match option_idx:
		1:
			opt_prefeitura.modulate = Color(0.9, 0.9, 1.0)
		2:
			opt_compesa.modulate = Color(0.9, 1.0, 0.9)
		3:
			opt_arpe.modulate = Color(1.0, 0.9, 0.9)

func _on_confirm_quiz_pressed():
	if selected_quiz_option == 0:
		return
		
	feedback_overlay.show()
	if selected_quiz_option == 2:
		feedback_title.text = "✅ CORRETO!"
		feedback_desc.text = "A COMPESA (Companhia Pernambucana de Saneamento) é a concessionária pública responsável pelo abastecimento de água e tratamento de esgoto na cidade do Recife."
	elif selected_quiz_option == 1:
		feedback_title.text = "❌ INCORRETO"
		feedback_desc.text = "A Prefeitura do Recife cuida da pavimentação de ruas, iluminação pública, limpeza urbana e Defesa Civil, mas o saneamento básico e abastecimento de água direta é de responsabilidade de uma empresa estadual específica."
	elif selected_quiz_option == 3:
		feedback_title.text = "❌ INCORRETO"
		feedback_desc.text = "A ARPE é a Agência Reguladora de Pernambuco. Ela fiscaliza a qualidade dos serviços públicos prestados e regula tarifas, mas a distribuição e manutenção direta da rede é da concessionária COMPESA."

func _on_feedback_ok_pressed():
	feedback_overlay.hide()
	if selected_quiz_option == 2:
		_show_screen("compesa")

func _on_call_compesa_pressed():
	_show_screen("calling")
	calling_status.text = "Ligando para 0800 081 0195..."
	calling_desc.text = "Simulando contato telefônico com a central de atendimento..."
	calling_ok_button.hide()
	
	await get_tree().create_timer(2.0).timeout
	
	calling_status.text = "📞 Chamada Finalizada!"
	calling_desc.text = "Protocolo de atendimento gerado: #202619472.\n\nCOMPESA registrou a queixa! Uma equipe de campo foi despachada para o Coque para restabelecer a tubulação rompida."
	calling_ok_button.show()
	
	if not GameManager.water_solved:
		GameManager.water_solved = true
		GameManager.add_satisfaction(10.0)
		_update_phone_ui_state()

func _on_calling_ok_pressed():
	hide()

func _update_phone_ui_state():
	var phone_unlocked := GameManager.current_stage >= 4
	
	if concepts_aluguel_social_container:
		concepts_aluguel_social_container.visible = GameManager.housing_solved or GameManager.current_stage >= 10
	
	if not phone_unlocked:
		water_problem_card.hide()
		if shelter_problem_card:
			shelter_problem_card.hide()
		if housing_problem_card:
			housing_problem_card.hide()
		home_problems_card.disabled = true
		home_contacts_card.disabled = true
		nav_problems.disabled = true
		nav_contacts.disabled = true
	else:
		water_problem_card.show()
		if shelter_problem_card:
			shelter_problem_card.show()
		if housing_problem_card:
			if GameManager.current_stage >= 9:
				housing_problem_card.show()
			else:
				housing_problem_card.hide()
		home_problems_card.disabled = false
		home_contacts_card.disabled = false
		nav_problems.disabled = false
		nav_contacts.disabled = false

	if GameManager.water_solved:
		water_status_tag.self_modulate = Color("4E8C50")
		water_status_label.text = "Resolvido"
		water_update_label.text = "Última atualização: Serviço concluído."
		
		detail_status_tag.self_modulate = Color("4E8C50")
		detail_status_label.text = "Resolvido"
		detail_resolve_button.text = "Problema Resolvido"
		detail_resolve_button.disabled = true
	else:
		water_status_tag.self_modulate = Color("A63F3F")
		water_status_label.text = "Não resolvido"
		water_update_label.text = "Última atualização: Em análise pela COMPESA."
		
		if active_problem == "water":
			detail_status_tag.self_modulate = Color("A63F3F")
			detail_status_label.text = " Não resolvido "
			detail_resolve_button.text = "Ver como resolver"
			detail_resolve_button.disabled = false

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

func _update_indicators_screen():
	ind_satisfacao_bar.value = GameManager.satisfaction
	ind_satisfacao_val.text = "%d%%" % int(GameManager.satisfaction)
	ind_saneamento_bar.value = 80.0 if GameManager.water_solved else 50.0

func _on_stage_changed(new_stage: int):
	if new_stage == 4:
		phone_glowing = true
		print("[PhoneMenu] Phone is glowing! Player needs to open phone.")

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

