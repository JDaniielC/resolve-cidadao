extends PointLight2D

const LIGHT_TEXTURE := preload("res://assets/effects/point_light_gradient.tres")

func _ready() -> void:
	energy = 0.8
	color = Color(1.0, 0.85, 0.4)
	texture_scale = 0.5
	blend_mode = PointLight2D.BLEND_MODE_ADD
	shadow_enabled = false
	call_deferred("_assign_texture")

func _assign_texture() -> void:
	if not is_instance_valid(self) or is_queued_for_deletion() or not is_inside_tree():
		return
	if LIGHT_TEXTURE:
		texture = LIGHT_TEXTURE
