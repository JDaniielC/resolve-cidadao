extends PathFollow2D

@export var velocidade: float = 30.0
@export var tempo_pausa: float = 3.0

var carro: Node2D = null
var sprite = null
var pode_andar: bool = false
var ja_completou_volta: bool = false

func _ready() -> void:
	loop = true
	_localizar_carro()
	_pausar_inicio()

func _pausar_inicio() -> void:
	pode_andar = false
	await get_tree().create_timer(tempo_pausa).timeout   # ⏱️ pausa
	pode_andar = true
	ja_completou_volta = false

func _localizar_carro() -> void:
	carro = get_node_or_null("CarNPC")

	if carro == null:
		for filho in get_children():
			print("Filho encontrado: ", filho.name, " | tipo: ", filho.get_class())
			if filho is Node2D:
				carro = filho
				break

	if carro == null:
		push_warning("Nenhum Node2D filho encontrado no PathFollow2D!")
		return

	for filho in carro.get_children():
		if filho is Sprite2D or filho is AnimatedSprite2D:
			sprite = filho
			break

func _process(delta: float) -> void:
	# 🔒 Enquanto não pode andar, trava no começo SEMPRE
	if not pode_andar:
		progress = 0.0
		_atualizar_sprite()
		return

	progress += velocidade * delta

	# 🔁 Detecta o fim da volta (chegou perto do final do caminho)
	if not ja_completou_volta and progress_ratio >= 0.99:
		ja_completou_volta = true
		_pausar_inicio()   # reinicia a pausa na próxima volta
		return

	_atualizar_sprite()

func _atualizar_sprite() -> void:
	if carro == null:
		return

	var indo_para_direita := cos(rotation) >= 0

	if sprite != null:
		sprite.flip_h = not indo_para_direita
	else:
		carro.scale.x = 1 if indo_para_direita else -1
