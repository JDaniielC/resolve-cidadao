extends Node2D
class_name CameraBounds

## Defines the visible map edges used by GameCamera limits.
@export var use_manual_bounds: bool = false
@export var manual_bounds: Rect2 = Rect2(0, 0, 1280, 720)
@export var padding: Vector2 = Vector2.ZERO
@export var auto_detect_tilemaps: bool = true

func get_world_bounds() -> Rect2:
	var rect: Rect2

	if use_manual_bounds:
		rect = manual_bounds
	elif auto_detect_tilemaps:
		rect = _detect_from_tilemaps()
		if rect.size == Vector2.ZERO:
			rect = manual_bounds
	else:
		rect = manual_bounds

	if padding != Vector2.ZERO:
		rect = rect.grow_individual(-padding.x, -padding.y, -padding.x, -padding.y)

	return rect

func _detect_from_tilemaps() -> Rect2:
	var level := get_parent()
	if not level:
		return Rect2()

	var merged := Rect2()
	var found := false

	for node in level.find_children("*", "TileMapLayer", true, false):
		var layer_rect := _tilemap_world_rect(node as TileMapLayer)
		if layer_rect.size == Vector2.ZERO:
			continue
		if not found:
			merged = layer_rect
			found = true
		else:
			merged = merged.merge(layer_rect)

	return merged if found else Rect2()

func _tilemap_world_rect(layer: TileMapLayer) -> Rect2:
	var used := layer.get_used_rect()
	if used.size == Vector2i.ZERO:
		return Rect2()

	var tile_size := Vector2(layer.tile_set.tile_size)
	var local := Rect2(Vector2(used.position) * tile_size, Vector2(used.size) * tile_size)
	var xf := layer.global_transform
	var corners: Array[Vector2] = [
		xf * local.position,
		xf * Vector2(local.end.x, local.position.y),
		xf * local.end,
		xf * Vector2(local.position.x, local.end.y),
	]

	var min_pos: Vector2 = corners[0]
	var max_pos: Vector2 = corners[0]

	for corner in corners:
		min_pos.x = min(min_pos.x, corner.x)
		min_pos.y = min(min_pos.y, corner.y)
		max_pos.x = max(max_pos.x, corner.x)
		max_pos.y = max(max_pos.y, corner.y)

	return Rect2(min_pos, max_pos - min_pos)
