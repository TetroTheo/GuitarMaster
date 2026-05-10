@tool
class_name Key
extends Button

var key_note : Note
signal key_pressed


func set_note(note: Note):
	key_note = note
	key_note.key = self
	text = note.note_name()


func _ready() -> void:
	self.custom_minimum_size.x = 42
	pressed.connect(on_key_press)


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
