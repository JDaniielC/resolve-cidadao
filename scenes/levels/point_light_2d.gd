extends PointLight2D

func _ready():
	var gradient = Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.set_color(1, Color(1, 1, 1, 0))
	
	var texture = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 256
	texture.height = 256
	
	self.texture = texture
	self.energy = 0.8
	self.color = Color(1.0, 0.85, 0.4)
	self.texture_scale = 0.5
	self.blend_mode = PointLight2D.BLEND_MODE_ADD
	self.shadow_enabled = false
