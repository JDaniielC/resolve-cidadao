@tool
extends RefCounted
class_name NPCGenerator

# Generate an NPC scene from sprite and dialogue paths
func generate(npc_name: String, sprite_path: String, dialogue_path: String) -> Result:
	# Validate inputs
	var validation = _validate_inputs(npc_name, sprite_path, dialogue_path)
	if validation.is_error():
		return validation

	# Calculate collision
	var collision_radius = _calculate_collision_radius(sprite_path)
	if collision_radius <= 0:
		return Result.error("Could not calculate collision from sprite")

	# Load template
	var template_scene = load("res://scenes/npcs/_npc_template.tscn")
	if not template_scene:
		return Result.error("NPC template not found at res://scenes/npcs/_npc_template.tscn")

	var npc_node = template_scene.instantiate()
	npc_node.name = npc_name

	# Set sprite
	var result = _set_sprite(npc_node, sprite_path)
	if result.is_error():
		return result

	# Set collision
	var collision_shape: CollisionShape2D = npc_node.get_node("CollisionShape2D")
	var capsule = CapsuleShape2D.new()
	capsule.radius = collision_radius
	capsule.height = collision_radius * 2.5
	collision_shape.shape = capsule

	# Set dialogue
	var dialogue_resource = load(dialogue_path)
	if not dialogue_resource:
		return Result.error("Dialogue file not found: %s" % dialogue_path)

	var start_dialogue = npc_node.get_node("StateMachine/start_dialogue")
	start_dialogue.dialogue = dialogue_resource

	# Save scene
	var save_path = "res://scenes/npcs/%s.tscn" % npc_name.to_lower().replace(" ", "_")

	# Check if file already exists
	if ResourceLoader.exists(save_path):
		return Result.error("NPC already exists: %s" % save_path)

	var packed_scene = PackedScene.new()
	packed_scene.pack(npc_node)

	var error = ResourceSaver.save(packed_scene, save_path)
	if error != OK:
		return Result.error("Failed to save scene: error code %d" % error)

	return Result.ok({
		"path": save_path,
		"name": npc_name,
		"collision_radius": collision_radius
	})

func _validate_inputs(npc_name: String, sprite_path: String, dialogue_path: String) -> Result:
	if npc_name.is_empty():
		return Result.error("NPC name cannot be empty")

	if not ResourceLoader.exists(sprite_path):
		return Result.error("Sprite not found: %s" % sprite_path)

	var ext = sprite_path.get_extension().to_lower()
	if ext not in ["png", "jpg", "jpeg"]:
		return Result.error("Sprite must be PNG or JPG, got: %s" % ext)

	if not ResourceLoader.exists(dialogue_path):
		return Result.error("Dialogue file not found: %s" % dialogue_path)

	if not dialogue_path.ends_with(".dialogue"):
		return Result.error("Dialogue must be .dialogue file")

	return Result.ok(null)

func _calculate_collision_radius(sprite_path: String) -> float:
	var image = Image.new()
	var error = image.load(sprite_path)
	if error != OK:
		return -1.0

	var width = image.get_width()
	var height = image.get_height()
	var max_size = maxf(width, height)

	# Formula: radius = max_dimension / 4
	# Sprite 96x128 → radius ≈ 32
	# Sprite 40x50 → radius ≈ 12-13
	return ceili(max_size / 4.0)

func _set_sprite(npc_node: Node, sprite_path: String) -> Result:
	var sprite: AnimatedSprite2D = npc_node.get_node("AnimatedSprite2D")
	var image = Image.new()
	var error = image.load(sprite_path)
	if error != OK:
		return Result.error("Could not load sprite image")

	var sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation("default")

	var texture = ImageTexture.create_from_image(image)
	sprite_frames.set_frame_duration("default", 0, 1.0)
	sprite_frames.set_frame_texture("default", 0, texture)

	sprite.sprite_frames = sprite_frames
	sprite.animation = "default"
	sprite.autoplay = "default"

	return Result.ok(null)

class Result:
	var _value: Variant
	var _error: String
	var _is_error: bool

	func _init(value: Variant = null, error: String = ""):
		_value = value
		_error = error
		_is_error = not error.is_empty()

	static func ok(value: Variant) -> Result:
		return Result.new(value, "")

	static func error(message: String) -> Result:
		return Result.new(null, message)

	func is_error() -> bool:
		return _is_error

	func is_ok() -> bool:
		return not _is_error

	func get_value() -> Variant:
		return _value

	func get_error() -> String:
		return _error
