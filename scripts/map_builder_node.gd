@tool
extends Node2D
class_name MapBuilderNode
## Nó simples para gerar mapas isométricos via Inspector

@export var map_name: String = "GeneratedMap"
@export var auto_generate: bool = false:
	get:
		return false
	set(_value):
		_generate_map()

@export_multiline var grid_string: String = """
....B..........B..
....B....G....B...
....G....G....G...
....G....G....G...
....G....G....G...
....B....P....B...
....B....P....B...
"""

@export var add_player: bool = true
@export var player_grid_pos: Vector2i = Vector2i(5, 3)
@export var player_scene: String = "res://entities/player/player.tscn"

var _generated_node: Node2D

const BASE_POSITION = Vector2(360, 150)
const TILE_OFFSET = Vector2(49, 24)
const TILE_SIZE = Vector2(64, 64)

func _ready() -> void:
	if not Engine.is_editor_hint():
		_generate_map()

func _generate_map() -> void:
	print("=== Iniciando geração de mapa ===")

	if _generated_node:
		_generated_node.queue_free()
		_generated_node = null

	var root = Node2D.new()
	root.name = map_name
	root.y_sort_enabled = true
	print("1. Node2D criado")

	# Parse grid
	var grid = _parse_grid(grid_string)
	print("2. Grid parseada: %d linhas" % grid.size())
	if grid.is_empty():
		push_error("Grid vazia!")
		return

	# Gerar tiles
	_create_tiles(root, grid)
	print("3. Tiles criados")

	# Gerar colliders
	_create_colliders(root, grid)
	print("4. Colliders criados")

	# Gerar entities
	_create_entities(root, grid)
	print("5. Entities criadas")

	_generated_node = root
	add_child(root)
	print("6. Node adicionado à cena")

	if Engine.is_editor_hint():
		root.owner = get_tree().edited_scene_root
		print("7. Owner setado")

	print("✓ Mapa gerado: %s (%dx%d)" % [map_name, grid.size(), grid[0].length() if grid else 0])

func _parse_grid(grid_str: String) -> Array:
	var lines = grid_str.split("\n")
	var result = []

	for line in lines:
		line = line.strip_edges()
		if line.is_empty():
			continue
		result.append(line)

	return result

func _create_tiles(parent: Node2D, grid: Array) -> void:
	var tile_grid = Node2D.new()
	tile_grid.name = "TileGrid"
	tile_grid.z_index = -1
	parent.add_child(tile_grid)

	var sprite_map = {
		'G': "res://assets/sprites/kenney/landscape/landscapeTiles_067.png",
		'B': "res://assets/sprites/kenney/landscape/landscapeTiles_066.png",
		'W': "res://assets/sprites/kenney/landscape/landscapeTiles_004.png",
		'S': "res://assets/sprites/kenney/landscape/landscapeTiles_067.png",
		'P': "res://assets/sprites/kenney/landscape/landscapeTiles_067.png",
	}

	for y in range(grid.size()):
		var line = grid[y]
		for x in range(line.length()):
			var char = line[x]
			if char == '.':
				continue

			var sprite = Sprite2D.new()
			sprite.position = _grid_to_screen(Vector2i(x, y))
			sprite.name = "Tile_%d_%d" % [x, y]

			if char in sprite_map:
				var path = sprite_map[char]
				if ResourceLoader.exists(path):
					sprite.texture = load(path)

			tile_grid.add_child(sprite)

func _create_colliders(parent: Node2D, grid: Array) -> void:
	var colliders = Node2D.new()
	colliders.name = "Colliders"
	colliders.z_index = 0
	parent.add_child(colliders)

	var solid = ['B', 'W']

	for y in range(grid.size()):
		var line = grid[y]
		for x in range(line.length()):
			if line[x] not in solid:
				continue

			var body = StaticBody2D.new()
			body.name = "Collider_%d_%d" % [x, y]

			var collision_shape = CollisionShape2D.new()
			var rect = RectangleShape2D.new()
			rect.size = TILE_SIZE
			collision_shape.shape = rect

			body.position = _grid_to_screen(Vector2i(x, y))
			body.add_child(collision_shape)
			colliders.add_child(body)

func _create_entities(parent: Node2D, grid: Array) -> void:
	var entities = Node2D.new()
	entities.name = "Entities"
	entities.z_index = 2
	entities.y_sort_enabled = true
	parent.add_child(entities)

	if add_player and player_scene and grid.size() > 0:
		var width = grid[0].length() if grid[0] is String else 0
		if player_grid_pos.x < width and player_grid_pos.y < grid.size():
			var player = load(player_scene).instantiate()
			player.position = _grid_to_screen(player_grid_pos)
			entities.add_child(player)

func _grid_to_screen(pos: Vector2i) -> Vector2:
	var x = pos.x
	var y = pos.y
	return Vector2(
		BASE_POSITION.x + (x * TILE_OFFSET.x) - (y * TILE_OFFSET.x),
		BASE_POSITION.y + (x * TILE_OFFSET.y) + (y * TILE_OFFSET.y)
	)

func clear_map() -> void:
	if _generated_node:
		_generated_node.queue_free()
		_generated_node = null
