extends Node2D
## Controller script for MainGame scene that manages pause menu integration and input handling

# Preload pause menu scene
var pause_menu_scene = preload("res://scenes/ui/menus/pause_menu.tscn")

var intro_overlay: ColorRect
var intro_layer: CanvasLayer

func _ready() -> void:
	# Connect to MenuController pause state signal
	MenuController.menu_state_changed.connect(_on_menu_state_changed)
	SceneManager.load_complete.connect(_on_level_loaded)
	
	# Create intro overlay to keep the screen dark
	intro_layer = CanvasLayer.new()
	intro_layer.layer = 1 # Above game (0) but below UILayer (2)
	add_child(intro_layer)
	
	intro_overlay = ColorRect.new()
	intro_overlay.color = Color.BLACK
	intro_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	intro_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE # Allow clicks to pass to dialogue
	intro_layer.add_child(intro_overlay)
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	await get_tree().create_timer(1.0).timeout
	
	# Disable player input during the intro dialogue
	for player in Globals.get_players():
		if player is PlayerEntity:
			player.input_enabled = false
			
	DialogueManager.show_dialogue_balloon(
		load("res://dialogues/missao_01/radio.dialogue"),
		"start"
	)

func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource and resource.resource_path.ends_with("radio.dialogue"):
		# Smoothly fade out the dark overlay
		if is_instance_valid(intro_overlay):
			var tween = create_tween()
			tween.tween_property(intro_overlay, "color", Color(0, 0, 0, 0), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			await tween.finished
		if is_instance_valid(intro_layer):
			intro_layer.queue_free()
		
		# Start the interactive HUD tutorial
		var hud = $HUD
		if hud and hud.has_method("start_tutorial"):
			hud.start_tutorial()
		else:
			# Fallback if no tutorial is found
			for player in Globals.get_players():
				if player is PlayerEntity:
					player.input_enabled = true

func _input(event: InputEvent) -> void:
	# Only handle ESC if game is not already paused
	if event.is_action_pressed("ui_cancel") and not MenuController.is_paused():
		_open_pause_menu()
		get_tree().root.set_input_as_handled()

func _open_pause_menu() -> void:
	## Open pause menu by toggling pause state and instantiating pause menu
	MenuController.toggle_pause()
	add_child(pause_menu_scene.instantiate())

func swap_level(scene_path: String, outgoing: Node) -> void:
	var incoming: Node = load(scene_path).instantiate()
	add_child(incoming)
	if outgoing and is_instance_valid(outgoing):
		outgoing.queue_free()
	await get_tree().process_frame
	var camera: GameCamera = $GameCamera2D
	if camera:
		camera.refresh_target()

func _on_level_loaded(_loaded_scene: Node) -> void:
	var camera: GameCamera = $GameCamera2D
	if camera:
		camera.refresh_target()

func _on_menu_state_changed(_is_paused: bool) -> void:
	## Handle menu state changes (pause/resume).
	##
	## Mouse routing is handled automatically by the engine: the pause menu is
	## a CanvasLayer overlay whose Control nodes capture clicks while it exists,
	## and clicks fall through to the game once it is freed. (`mouse_filter` is a
	## per-Control property, not a method on the global `Input` singleton, so the
	## previous `Input.set_mouse_filter(...)` calls were invalid and never ran.)
	pass
