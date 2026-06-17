class_name EmojiFont
extends RefCounted

const FONT: FontFile = preload("res://assets/fonts/NotoColorEmoji.ttf")


static func apply_to(control: Control) -> void:
	control.add_theme_font_override("font", FONT)
