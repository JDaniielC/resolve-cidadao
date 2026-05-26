@tool
extends EditorPlugin

var dock: Control

func _enter_tree():
	# Create and add the dock
	dock = preload("res://scripts/editor/npc_generator_dock.gd").new()
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)

func _exit_tree():
	if dock:
		remove_control_from_docks(dock)
		dock.queue_free()
