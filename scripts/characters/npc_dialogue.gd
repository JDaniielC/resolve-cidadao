# scripts/characters/npc_dialogue.gd
# NPC genérico de diálogo (reutilizável / placeholder).
# A interação em si (apertar para conversar) é feita pela StateMachine da cena
# (StateInteract -> StateDialogue, que aponta para o .dialogue). Este script só
# cuida da proximidade com o player e de uma trava opcional por stage.
extends CharacterBody2D

## Se >= 0, o NPC só fica interativo a partir deste stage do GameManager.
@export var active_from_stage: int = -1

var can_interact := false

func _ready() -> void:
	var area := get_node_or_null("InteractionArea")
	if area:
		area.body_entered.connect(_on_entered)
		area.body_exited.connect(_on_exited)
		area.area_entered.connect(func(a): _on_entered(a.get_parent()))
		area.area_exited.connect(func(a): _on_exited(a.get_parent()))

func _on_entered(node: Node) -> void:
	if node == null or not node.is_in_group("player"):
		return
	if active_from_stage >= 0 and GameManager.current_stage < active_from_stage:
		return
	can_interact = true
	if node.has_method("set_npc_proximity"):
		node.set_npc_proximity(self)

func _on_exited(node: Node) -> void:
	if node == null or not node.is_in_group("player"):
		return
	can_interact = false
	if node.has_method("set_npc_proximity"):
		node.set_npc_proximity(null)
