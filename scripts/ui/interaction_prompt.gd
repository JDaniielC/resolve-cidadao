# scripts/ui/interaction_prompt.gd
extends Control

@onready var label = $PanelContainer/Label
@onready var anim_player = $AnimationPlayer

func _ready():
	hide()
	modulate.a = 0

func show_prompt(text: String = "[E]"):
	label.text = text
	show()
	if anim_player.has_animation("fade_in"):
		anim_player.play("fade_in")
	else:
		create_tween().tween_property(self, "modulate:a", 1.0, 0.2)
	
	# Small pop effect
	create_tween().tween_property(self, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_BACK)
	create_tween().parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.1)

func hide_prompt():
	if anim_player.has_animation("fade_out"):
		anim_player.play("fade_out")
		await anim_player.animation_finished
	else:
		await create_tween().tween_property(self, "modulate:a", 0.0, 0.2).finished
	hide()
