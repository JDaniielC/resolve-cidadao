## This script is attached to the Player node and is specifically designed to represent player entities in the game.
## The Player node serves as the foundation for creating main playable characters.
class_name PlayerEntity
extends CharacterEntity

@export_group("States")
@export var on_transfer_start: State ## State to enable when player starts transfering.
@export var on_transfer_end: State ## State to enable when player ends transfering.

var player_id: int = 1 ## A unique id that is assigned to the player on creation. Player 1 will have player_id = 1 and each additional player will have an incremental id, 2, 3, 4, and so on.
var equipped = 0 ## The id of the weapon equipped by the player.
var nearby_npc = null ## Reference to NPC in proximity for interaction

@onready var _anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	super._ready()
	
	print("=== PLAYER ===")
	print("Layer:", collision_layer)
	print("Mask:", collision_mask)
	Globals.transfer_start.connect(func(): 
		on_transfer_start.enable()
	)
	Globals.transfer_complete.connect(func(): on_transfer_end.enable())
	Globals.destination_found.connect(func(destination_path): _move_to_destination(destination_path))
	receive_data(DataManager.get_player_data(player_id))

##Get the player data to save.
func get_data():
	var data = DataPlayer.new()
	var player_data = DataManager.get_player_data(player_id)
	if player_data:
		data = player_data
	data.position = position
	data.facing = facing
	data.inventory = inventory.items if inventory else []
	data.equipped = equipped
	return data

##Handle the received player data (from a save file or when moving to another level).
func receive_data(data):
	if data:
		global_position = data.position
		facing = data.facing
		if inventory:
			inventory.items = data.inventory
		equipped = data.equipped

func _move_to_destination(destination_path: String):
	if !destination_path:
		return
	var destination = get_tree().root.get_node(destination_path)
	if !destination:
		return
	var direction = facing
	if destination is Transfer and destination.direction:
		direction = destination.direction.to_vector
	DataManager.save_player_data(player_id, {
		position = destination.global_position,
		facing = direction
	})

func disable_entity(value: bool, delay = 0.0):
	await get_tree().create_timer(delay).timeout
	stop()
	input_enabled = !value

func set_npc_proximity(npc_ref = null):
	nearby_npc = npc_ref if npc_ref else null

func _process(delta):
	super._process(delta)
	if Input.is_action_just_pressed("interact") and nearby_npc:
		print("Player pressed E, triggering dialogue with NPC")
		nearby_npc.trigger_dialogue()
	_update_sprite_animation()

## Updates AnimatedSprite2D based on current facing direction and movement state.
func _update_sprite_animation():
	if not _anim_sprite:
		return

	var dir_suffix = _facing_to_suffix(facing)
	var prefix: String

	if is_running:
		prefix = "run"
	elif is_moving:
		prefix = "walk"
	else:
		prefix = "idle"

	var anim = prefix + "-" + dir_suffix

	# Fallback to walk if run animation doesn't exist
	if not _anim_sprite.sprite_frames.has_animation(anim):
		anim = "walk-" + dir_suffix
	if not _anim_sprite.sprite_frames.has_animation(anim):
		anim = "idle-" + dir_suffix

	if _anim_sprite.animation != anim or not _anim_sprite.is_playing():
		_anim_sprite.play(anim)

## Converts a facing Vector2 to a direction string suffix.
func _facing_to_suffix(dir: Vector2) -> String:
	if abs(dir.y) >= abs(dir.x):
		return "down" if dir.y >= 0 else "up"
	else:
		return "right" if dir.x > 0 else "left"
		
func _physics_process(delta):
	super._physics_process(delta)

	if Input.is_action_just_pressed("interact"):
		print("Player Layer:", collision_layer)
		print("Player Mask:", collision_mask)
