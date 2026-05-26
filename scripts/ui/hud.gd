# scripts/ui/hud.gd
extends CanvasLayer

@onready var stage_label = $StageLabel
@onready var objective_label = $ObjectiveLabel

func _ready():
	GameManager.stage_changed.connect(_on_stage_changed)
	_update_display()

func _update_display():
	stage_label.text = "Etapa %d/4" % GameManager.current_stage
	objective_label.text = GameManager.get_objective()

func _on_stage_changed(new_stage: int):
	_update_display()
