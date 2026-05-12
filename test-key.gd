@tool
class_name Key
extends Button

var key_note : Note
signal key_pressed


func set_note(note: Note):
	key_note = note
	key_note.key = self
	text = note.note_name()


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


## for now, toggling is purely visual

func toggle_on():
	toggle_mode = true
	button_pressed = true


func toggle_off():
	toggle_mode = false
	button_pressed = false
