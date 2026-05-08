@tool
class_name Key
extends Button

var key_note : Note
signal key_pressed


func set_note(note: Note):
	key_note = note
	text = note.note_name()


func _ready() -> void:
	self.custom_minimum_size.x = 42
	pressed.connect(on_key_press)


func on_key_press():
	print(key_note)
	key_pressed.emit(key_note)
