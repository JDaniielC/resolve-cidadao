# scripts/ui/mission_complete.gd
extends CanvasLayer

@onready var satisfaction_label: Label = $Panel/VBox/StatsBox/SatisfactionLabel
@onready var satisfaction_bar: ProgressBar = $Panel/VBox/StatsBox/SatisfactionBar
@onready var assessment_label: Label = $Panel/VBox/StatsBox/AssessmentLabel
@onready var continue_button: Button = $Panel/VBox/ButtonsBox/ContinueButton
@onready var credits_button: Button = $Panel/VBox/ButtonsBox/CreditsButton
@onready var anim_player: AnimationPlayer = get_node_or_null("AnimationPlayer")
@onready var stars_particles: CPUParticles2D = $StarsParticles

var credits_scene = preload("res://scenes/ui/menus/credits_menu.tscn")

func _ready() -> void:
	hide()
	continue_button.pressed.connect(_on_continue_pressed)
	credits_button.pressed.connect(_on_credits_pressed)

func show_mission_complete(assessment_score: int = -1, assessment_total: int = 0) -> void:
	GameManager.complete_game()
	GameManager.pause_game()
	show()
	
	# Update UI with final stats
	var final_satisfaction := int(GameManager.satisfaction)
	satisfaction_label.text = "%d%% de Satisfação" % final_satisfaction
	satisfaction_bar.value = final_satisfaction

	if assessment_score >= 0 and assessment_total > 0:
		var percent := int(round(float(assessment_score) / float(assessment_total) * 100.0))
		assessment_label.text = "Avaliação: %d/%d acertos (%d%%)" % [assessment_score, assessment_total, percent]
		assessment_label.show()
	else:
		assessment_label.hide()
	
	# Play particles
	if stars_particles:
		stars_particles.emitting = true
	
	# Animate entrance
	if anim_player and anim_player.has_animation("show"):
		anim_player.play("show")

func _on_continue_pressed() -> void:
	GameManager.resume_game()
	hide()

func _on_credits_pressed() -> void:
	var tree = get_tree()
	# Load credits scene
	tree.change_scene_to_file("res://scenes/ui/menus/credits_menu.tscn")
