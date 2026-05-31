extends CPUParticles2D

func _ready():
	# Textura: retângulo fino simulando gota
	var img = Image.create(2, 16, false, Image.FORMAT_RGBA8)
	for y in range(16):
		var alpha = 1.0 - (float(y) / 16.0) * 0.5
		img.set_pixel(0, y, Color(0.7, 0.85, 1.0, alpha))
		img.set_pixel(1, y, Color(0.7, 0.85, 1.0, alpha))
	
	self.texture = ImageTexture.create_from_image(img)
	
	# Configurações da chuva
	self.emitting = true
	self.amount = 300
	self.lifetime = 1.8
	self.explosiveness = 0.0
	self.direction = Vector2(0.15, 1.0)
	self.spread = 5.0
	self.gravity = Vector2(0, 0)
	self.initial_velocity_min = 300.0
	self.initial_velocity_max = 400.0
	self.scale_amount_min = 1.0
	self.scale_amount_max = 1.5
	
	# Área de emissão cobrindo toda a tela
	self.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	self.emission_rect_extents = Vector2(1000, 10)
	self.position = Vector2(640, -20)
