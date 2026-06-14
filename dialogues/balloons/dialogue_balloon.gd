extends DialogueManagerExampleBalloon
## An extension of the basic dialogue balloon for use with Dialogue Manager.

## The container for the name label.
@onready var name_container: Panel = $Balloon/NameContainer
@onready var next_button: Button = %NextButton

func _ready() -> void:
	super._ready()
	next_button.pressed.connect(_on_next_button_pressed)
	
	# Hide HUD interaction button while dialogue is active to avoid overlap
	var hud = get_tree().root.find_child("HUD", true, false)
	if hud:
		if hud.has_method("set_interact_button_visible"):
			hud.set_interact_button_visible(false)
		if hud.has_method("set_joystick_visible"):
			hud.set_joystick_visible(false)
		
		tree_exited.connect(func(): 
			if is_instance_valid(hud):
				if hud.has_method("set_interact_button_visible"):
					hud.set_interact_button_visible(true)
				if hud.has_method("set_joystick_visible"):
					hud.set_joystick_visible(true)
		)

func _process(delta: float) -> void:
	super._process(delta)
	if is_instance_valid(dialogue_line):
		next_button.visible = dialogue_line.responses.size() == 0

## Apply any changes to the balloon given a new [DialogueLine].
func apply_dialogue_line() -> void:
	super.apply_dialogue_line()
	name_container.visible = not dialogue_line.character.is_empty()

func _on_next_button_pressed() -> void:
	if dialogue_label.is_typing:
		dialogue_label.skip_typing()
		return
	
	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return
	
	next(dialogue_line.next_id)
