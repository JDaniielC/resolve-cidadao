# scripts/ui/hud.gd
extends CanvasLayer

@onready var stage_label = $StageLabel
@onready var objective_label = $ObjectiveLabel
@onready var cellphone_button = $CellphoneButton

func _ready():
	GameManager.stage_changed.connect(_on_stage_changed)
	cellphone_button.pressed.connect(_on_cellphone_pressed)
	_update_display()

func _update_display():
	stage_label.text = "Etapa %d/4" % GameManager.current_stage
	objective_label.text = GameManager.get_objective()

func _on_stage_changed(new_stage: int):
	_update_display()

## Open/close the phone menu. Reaches the PhoneMenu through the scene tree,
## following the same pattern used in dialogue_box.gd.
func _on_cellphone_pressed():
	var phone = get_tree().root.get_node_or_null("MainGame/UILayer/PhoneMenu")
	if phone:
		phone.toggle()
