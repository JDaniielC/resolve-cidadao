extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Carro atingiu o player! 🚨")
		# Aqui você decide: dar dano, empurrar, game over, etc.
		_aplicar_efeito(body)

func _aplicar_efeito(body: Node2D) -> void:
	# Exemplo: empurrar o player na direção do movimento do carro
	if body.has_method("levar_atropelo"):
		body.levar_atropelo()
