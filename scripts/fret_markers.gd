extends Panel

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("show_fret_markers"):
		show()
	if Input.is_action_just_released("show_fret_markers"):
		hide()
