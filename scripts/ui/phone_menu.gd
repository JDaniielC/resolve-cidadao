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

# Problem Detail Buttons
@onready var detail_resolve_button = $Panel/VBoxContainer/ContentView/ProblemDetailView/VBox/MarginContainer/ResolveButton
@onready var detail_status_tag = $Panel/VBoxContainer/ContentView/ProblemDetailView/VBox/Card/Margin/VBox/HBox/StatusTag
@onready var detail_status_label = $Panel/VBoxContainer/ContentView/ProblemDetailView/VBox/Card/Margin/VBox/HBox/StatusTag/Label

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

var current_screen: String = "home"
var selected_quiz_option: int = 0 # 1=Prefeitura, 2=COMPESA, 3=ARPE
var phone_glowing: bool = false

func _ready():
	hide()
	
	# General Buttons
	back_button.pressed.connect(_on_back_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	# Bottom Navigation
	nav_home.pressed.connect(func(): _show_screen("home"))
	nav_problems.pressed.connect(func(): _show_screen("problems_list"))
	nav_contacts.pressed.connect(func(): _show_screen("compesa" if GameManager.current_stage >= 5 else "home"))
	nav_indicators.pressed.connect(func(): _show_screen("indicators"))
	
	# Home Cards
	home_problems_card.pressed.connect(func(): _show_screen("problems_list"))
	home_contacts_card.pressed.connect(func(): _show_screen("compesa" if GameManager.current_stage >= 5 else "home"))
	home_satisfaction_card.pressed.connect(func(): _show_screen("indicators"))
	home_concepts_card.pressed.connect(func(): _show_screen("concepts"))
	
	# Problems List
	water_problem_card.pressed.connect(func(): _show_screen("problem_detail"))
	
	# Problem Detail
	detail_resolve_button.pressed.connect(func(): _show_screen("quiz"))
	
	# Quiz Options
	opt_prefeitura.pressed.connect(func(): _select_quiz_option(1))
	opt_compesa.pressed.connect(func(): _select_quiz_option(2))
	opt_arpe.pressed.connect(func(): _select_quiz_option(3))
	confirm_quiz_button.pressed.connect(_on_confirm_quiz_pressed)
	feedback_ok_button.pressed.connect(_on_feedback_ok_pressed)
	
	# Contact COMPESA
	compesa_call_button.pressed.connect(_on_call_compesa_pressed)
	
	# Calling OK
	calling_ok_button.pressed.connect(_on_calling_ok_pressed)
	
	# Signals from GameManager
	GameManager.stage_changed.connect(_on_stage_changed)
	
	# Initialize default state
	_update_phone_ui_state()
	_show_screen("home")

func toggle():
	visible = not visible
	if visible:
		# If user opened the phone at stage 3, advance to stage 4
		if GameManager.current_stage == 3:
			print("[PhoneMenu] Player opened phone at stage 3, advancing to stage 4 (Quiz)...")
			GameManager.advance_stage()
		_update_phone_ui_state()
		_show_screen("home")

func _show_screen(screen_name: String):
	current_screen = screen_name
	
	# Hide all views
	home_view.hide()
	problems_list_view.hide()
	problem_detail_view.hide()
	quiz_view.hide()
	compesa_view.hide()
	calling_view.hide()
	indicators_view.hide()
	concepts_view.hide()
	feedback_overlay.hide()
	
	# Toggle views & titles
	match screen_name:
		"home":
			home_view.show()
			header_title.text = "GESTÃO DA CIDADE"
			back_button.hide()
		"problems_list":
			problems_list_view.show()
			header_title.text = "REGISTRO DE PROBLEMAS"
			back_button.show()
		"problem_detail":
			problem_detail_view.show()
			header_title.text = "REGISTRO DE PROBLEMAS"
			back_button.show()
		"quiz":
			quiz_view.show()
			header_title.text = "QUEM É RESPONSÁVEL?"
			back_button.show()
			_select_quiz_option(0) # Clear previous selection
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
			header_title.text = "SATISFAÇÃO DA CIDADE"
			back_button.show()
			_update_indicators_screen()
		"concepts":
			concepts_view.show()
			header_title.text = "APRENDIZADOS"
			back_button.show()
			
	_update_phone_ui_state()

func _on_back_pressed():
	match current_screen:
		"problems_list", "indicators", "concepts":
			_show_screen("home")
		"problem_detail":
			_show_screen("problems_list")
		"quiz":
			_show_screen("problem_detail")
		"compesa":
			if GameManager.current_stage == 5:
				_show_screen("quiz")
			else:
				_show_screen("home")

func _on_close_pressed():
	hide()

func _select_quiz_option(option_idx: int):
	selected_quiz_option = option_idx
	
	# Reset visual borders
	opt_prefeitura.modulate = Color.WHITE
	opt_compesa.modulate = Color.WHITE
	opt_arpe.modulate = Color.WHITE
	
	# Highlight selected
	match option_idx:
		1:
			opt_prefeitura.modulate = Color(0.9, 0.9, 1.0) # Light blue
		2:
			opt_compesa.modulate = Color(0.9, 1.0, 0.9) # Light green
		3:
			opt_arpe.modulate = Color(1.0, 0.9, 0.9) # Light red

func _on_confirm_quiz_pressed():
	if selected_quiz_option == 0:
		return # No option selected
		
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
		if GameManager.current_stage == 4:
			print("[PhoneMenu] Quiz correct! Advancing to stage 5 (Acionar Solução)...")
			GameManager.advance_stage()
		_show_screen("compesa")

func _on_call_compesa_pressed():
	_show_screen("calling")
	calling_status.text = "Ligando para 0800 081 0195..."
	calling_desc.text = "Simulando contato telefônico com a central de atendimento..."
	calling_ok_button.hide()
	
	# Simulate 2 seconds of call ringing/connecting
	await get_tree().create_timer(2.0).timeout
	
	calling_status.text = "📞 Chamada Finalizada!"
	calling_desc.text = "Protocolo de atendimento gerado: #202619472.\n\nCOMPESA registrou a queixa! Uma equipe de campo foi despachada para o Coque para restabelecer a tubulação rompida."
	calling_ok_button.show()
	
	# Apply game progression consequences!
	if not GameManager.water_solved:
		GameManager.water_solved = true
		GameManager.add_satisfaction(10.0) # Increase satisfaction by 10%
		if GameManager.current_stage == 5:
			print("[PhoneMenu] Call completed! Advancing to stage 6 (Retorno Narrativo)...")
			GameManager.advance_stage()
		
		# Update values in views immediately
		_update_phone_ui_state()

func _on_calling_ok_pressed():
	hide() # Close phone so player can return to Dona Maria

func _update_phone_ui_state():
	# Progression gate: hide tasks and contacts if stage is too low (before conversing with Dona Maria)
	if GameManager.current_stage < 3:
		water_problem_card.hide()
		home_problems_card.disabled = true
		home_contacts_card.disabled = true
		nav_problems.disabled = true
		nav_contacts.disabled = true
	else:
		water_problem_card.show()
		home_problems_card.disabled = false
		nav_problems.disabled = false
		
		# Contacts (COMPESA) only unlocked at stage 5+ (after quiz is answered)
		if GameManager.current_stage >= 5 or GameManager.water_solved:
			home_contacts_card.disabled = false
			nav_contacts.disabled = false
		else:
			home_contacts_card.disabled = true
			nav_contacts.disabled = true

	if GameManager.water_solved:
		# Redefine Problem status in list to RESOLVED
		water_status_tag.self_modulate = Color("4E8C50") # Green tag color
		water_status_label.text = "Resolvido"
		water_update_label.text = "Última atualização: Serviço concluído."
		
		# Redefine Problem status in details
		detail_status_tag.self_modulate = Color("4E8C50")
		detail_status_label.text = "Resolvido"
		detail_resolve_button.text = "Problema Resolvido"
		detail_resolve_button.disabled = true
	else:
		# Unresolved state
		water_status_tag.self_modulate = Color("A63F3F") # Red tag color
		water_status_label.text = "Não resolvido"
		water_update_label.text = "Última atualização: Em análise pela COMPESA."
		
		detail_status_tag.self_modulate = Color("A63F3F")
		detail_status_label.text = "Não resolvido"
		detail_resolve_button.text = "Ver como resolver"
		detail_resolve_button.disabled = false

func _update_indicators_screen():
	# Dynamically update the Indicators screen matching the actual game state
	ind_satisfacao_bar.value = GameManager.satisfaction
	ind_satisfacao_val.text = "%d%%" % int(GameManager.satisfaction)
	ind_saneamento_bar.value = 80.0 if GameManager.water_solved else 50.0

func _on_stage_changed(new_stage: int):
	if new_stage == 3:
		phone_glowing = true
		print("[PhoneMenu] Phone is glowing! Player needs to open phone.")
