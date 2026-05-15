@tool
extends MarginContainer

@export var margin_value = 100

func _ready() -> void:
	## This code sample assumes the current script is extending MarginContainer.
	add_theme_constant_override("margin_top", margin_value)
	add_theme_constant_override("margin_left", margin_value)
	add_theme_constant_override("margin_bottom", margin_value)
	add_theme_constant_override("margin_right", margin_value)
