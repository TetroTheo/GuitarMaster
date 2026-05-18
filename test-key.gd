@tool
class_name Key
extends Button

var key_note : Note
signal key_pressed


func set_note(note: Note):
	key_note = note
	#key_note.key = self
	$Label.text = note.note_name()
	size_flags_horizontal = Control.SIZE_FILL
	custom_minimum_size.y = 24


## this class does not have a scene, so we have to handle
## all connections and child nodes through code!
func _ready() -> void:
	pressed.connect(on_key_press)


## useful because different frets may have different sizes
func set_length(length) -> void:
	custom_minimum_size.x = length


func on_key_press():
	print(key_note)
	key_pressed.emit(key_note)


func on_update_key_scale(new_pitch: int, new_interval: int):
	if key_note.same_note_name_as(new_pitch):
		self_modulate = Color.MEDIUM_SPRING_GREEN
	elif key_note.in_scale(new_pitch, new_interval):
		self_modulate = Color.MEDIUM_TURQUOISE
	else:
		self_modulate = Color.WHITE


## for now, toggling is purely visual

func toggle_on():
	toggle_mode = true
	button_pressed = true


func toggle_off():
	toggle_mode = false
	button_pressed = false
