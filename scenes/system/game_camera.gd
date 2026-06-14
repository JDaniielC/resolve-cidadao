## Handle main camera movement and target following.
class_name GameCamera
extends Camera2D

const DEFAULT_LIMIT_LEFT := -10000000
const DEFAULT_LIMIT_TOP := -10000000
const DEFAULT_LIMIT_RIGHT := 10000000
const DEFAULT_LIMIT_BOTTOM := 10000000

@export var target_manager: TargetManager

func _ready() -> void:
	_enable_smoothing(false)
	zoom = Vector2(2.5, 2.5) # Focus closer to the character (2.5x)
	target_manager.target_reached.connect(_init_camera)

func _physics_process(_delta: float) -> void:
	_follow_target()

##internal - When transitioning between levels, the camera will be activated upon completing the transfer.
func _init_camera():
	_enable_smoothing(true)

func _enable_smoothing(value):
	position_smoothing_enabled = value

##internal - Manages camera tracking of the assigned target.
func _follow_target():
	if target_manager:
		global_position = target_manager.get_target_position()

func apply_level_bounds(level: Node) -> void:
	var bounds_node := level.find_child("CameraBounds", true, false) as CameraBounds
	if bounds_node:
		_set_limits(bounds_node.get_world_bounds())
	else:
		clear_limits()

func clear_limits() -> void:
	limit_left = DEFAULT_LIMIT_LEFT
	limit_top = DEFAULT_LIMIT_TOP
	limit_right = DEFAULT_LIMIT_RIGHT
	limit_bottom = DEFAULT_LIMIT_BOTTOM

func _set_limits(rect: Rect2) -> void:
	limit_left = int(rect.position.x)
	limit_top = int(rect.position.y)
	limit_right = int(rect.end.x)
	limit_bottom = int(rect.end.y)

func refresh_target() -> void:
	if target_manager:
		target_manager.target = null
		target_manager.target_player_id = 1
