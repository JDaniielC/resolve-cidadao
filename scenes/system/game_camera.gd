## Handle main camera movement and target following.
class_name GameCamera
extends Camera2D

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

func refresh_target() -> void:
	if target_manager:
		target_manager.target = null
		target_manager.target_player_id = 1
