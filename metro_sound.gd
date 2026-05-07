#@tool
extends AudioStreamPlayer
@onready var timer = $"../MetroTimer"

func _on_metro_value_changed(value: float) -> void:
	#timer.stop()
	timer.wait_time = 60/value
	#timer.start()


func _on_play_toggled(toggled_on: bool) -> void:
	if toggled_on:
		timer.start()
	else:
		timer.stop()


func _on_metro_timer_timeout() -> void:
	play()
	#print()
