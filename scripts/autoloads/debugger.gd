extends Node

func _ready():
	if not OS.is_debug_build():
		set_process_unhandled_key_input(false)
		print("DEBUGGER DISABLED.")
		return

func _unhandled_key_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				DataManager.save_game()
			KEY_CTRL:
				_set_player_ghost()
			KEY_TAB:
				_toggle_screen_view()
			KEY_0:
				_reset_player_velocity()
			KEY_5:
				_stop_all_enemies()

## Disables/enables players CollisionShape2D, allowing them to pass through anything.
func _set_player_ghost():
	for player in Globals.get_players():
		var coll: CollisionShape2D = player.get_node_or_null("CollisionShape2D")
		if coll:
			coll.disabled = !coll.disabled

func _toggle_screen_view():
	for player: PlayerEntity in Globals.get_players():
		player.visible = !player.visible


## Set players velocity to zero.
func _reset_player_velocity():
	for player in Globals.get_players():
		player.velocity = Vector2.ZERO

## Disables/enables the process of all enemies in the scene.
func _stop_all_enemies():
	var enemies = get_tree().get_nodes_in_group(Const.GROUP.ENEMY)
	for enemy in enemies:
		if enemy.process_mode == Node.PROCESS_MODE_DISABLED:
			enemy.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			enemy.process_mode = Node.PROCESS_MODE_DISABLED
